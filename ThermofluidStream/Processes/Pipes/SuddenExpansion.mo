within ThermofluidStream.Processes.Pipes;
model SuddenExpansion "Pressure drop due to expansion using Modelica.Fluid.Dissipation.PressureLoss.Orifice"

  extends Internal.Interfaces.SISOFlow_nonConstArea(final L=L_value, final clip_p_out=true);

  //Geometry
  parameter SI.Length d_1 "Inlet diameter"
    annotation(Dialog(group="Geometry"));
  parameter SI.Length d_2 "Outlet diameter"
    annotation(Dialog(group="Geometry"));
  //Initialization
  parameter ThermofluidStream.Utilities.Types.InitializationMethods initdp = ThermofluidStream.Utilities.Types.InitializationMethods.none "Initialization method for pressure difference dp"
    annotation(Dialog(tab = "Initialization", group = "Pressure difference"), choicesAllMatching = true);
  parameter SI.Pressure dp_0 = 0 "Initial value for pressure difference dp"
    annotation(Dialog(tab = "Initialization", group = "Pressure difference", enable = (initdp == ThermofluidStream.Utilities.Types.InitializationMethods.state)));
  parameter ThermofluidStream.Utilities.Units.MassFlowAcceleration dp_acceleraton_0 = 0 "Initial value for der(dp)"
    annotation(Dialog(tab = "Initialization", group = "dp", enable = (initdp == ThermofluidStream.Utilities.Types.InitializationMethods.derivative)));
  // no default value to require the modeler to think about it; use final to suppress this option to user
  //Advanced
  parameter SI.Density rho_min = dropOfCommons.rho_min "Minimal density"
    annotation(Dialog(tab = "Advanced"));
  parameter StateSelect dpStateSelect = StateSelect.default "State select for pressure difference dp"
    annotation(Dialog(tab = "Advanced"));
  parameter ThermofluidStream.Utilities.Units.Inertance L_value = dropOfCommons.L "Inertance of pipe"
    annotation(Dialog(tab = "Advanced"));
  parameter Boolean assumeConstantMaterialProperties=true "= true, if constant density and dynamic viscosity is assumed (use '= false' e.g. for Ma > 0.3)"
    annotation(Evaluate=true, HideResult=true, choices(checkBox=true));

  SI.Density rho "Mean density";
  SI.DynamicViscosity mu "Mean dynamic viscosity";
  final parameter Modelica.Fluid.Dissipation.PressureLoss.Orifice.dp_suddenChange_IN_con In_con(
    A_1=A_1,
    A_2=A_2,
    C_1=d_1,
    C_2=d_2) "Input record constants";
  Modelica.Fluid.Dissipation.PressureLoss.Orifice.dp_suddenChange_IN_var In_var(eta=mu, rho=rho) "Input record variables";
  SI.ReynoldsNumber Re = d_1*abs(m_flow)/A_1/mu "Reynolds number";
protected
  SI.Density rho_in = max(rho_min, Medium.density(inlet.state)) "Inlet density";
  SI.Density rho_out = if assumeConstantMaterialProperties then rho_in else max(rho_min, Medium.density(outlet.state)) "Outlet density";
  SI.DynamicViscosity mu_in = Medium.dynamicViscosity(inlet.state) "Inlet dynamic viscosity";
  SI.DynamicViscosity mu_out = if assumeConstantMaterialProperties then mu_in else Medium.dynamicViscosity(outlet.state) "Outlet dynamic viscosity";
  final parameter SI.Area A_1 = pi/4*d_1^2 "Inlet cross-sectional area";
  final parameter SI.Area A_2 = pi/4*d_2^2 "Outlet cross-sectional area";
equation
  // Computation of mean dynamic viscosity and mean density
  mu = (mu_in + mu_out)/2;
  rho = (rho_in + rho_out)/2;
  // Computation of inlet and outlet velocity
  c_in = m_flow/rho/A_1;
  c_out = m_flow/rho/A_2;
  -dp = Modelica.Fluid.Dissipation.PressureLoss.Orifice.dp_suddenChange_DP(
    In_con,
    In_var,
    m_flow);
  h_out = h_in;
  Xi_out = Xi_in;
  assert(m_flow > 0 and Re > 3.3e3 or m_flow < 0 and Re > 1e4, "Reynolds number is below valid flow regime. Simulation results might be incorrect!", AssertionLevel.warning);
  annotation (
    defaultComponentName = "sudden_expansion",
    Documentation(info="",                                         revisions=""),
    Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}), graphics={
      Text(visible=displayInstanceName,
          extent={{-150,110},{150,70}},
          textString="%name",
          textColor=dropOfCommons.instanceNameColor),
      Line(
          points={{-80,30},{-10,30},{-10,50},{80,50}},
          color={0,140,72},
          thickness=0.5),
      Line(
          points={{-80,-30},{-10,-30},{-10,-50},{80,-50}},
          color={0,140,72},
          thickness=0.5),
        Polygon(
          points={{-80,20},{-80,-20},{0,-20},{0,-40},{80,-40},{80,40},{0,40},{0,20},{-80,20}},
          lineColor={0,140,72},
          fillColor={170,255,170},
          fillPattern=FillPattern.Solid)}));
end SuddenExpansion;