

<cfcomponent>
	<cffunction name="test" access="remote" >
		<cfset var slatwallApplication = createObject("component", "Slatwall.Application") />

		<!--- Reload Slatwall --->
		<cfset slatwallApplication.bootstrap() />
		<cfset request.slatwallScope.getAccount().setSuperUserFlag(1)/>
		<cfset $.slatwall = request.slatwallScope/>
		<cfheader
		    name = "Content-Type"
		    value = "text/html">
		<cfsavecontent variable="local.specrunnerOutput" >
			<cfoutput>
				<!DOCTYPE html>
				<html >
					<head>
					  <meta charset="utf-8">
						<meta http-equiv="X-UA-Compatible" content="IE=edge">

					  <title>Jasmine Spec Runner </title>
					  <meta name="viewport" content="width=device-width,initial-scale=1.0">

						<cfif CGI.HTTP_USER_AGENT CONTAINS "MSIE 9">
							<cfset baseHREF=request.slatwallScope.getBaseURL() />
							<cfif len(baseHREF) gt 1>
								<cfset baseHREF = right(baseHREF, len(baseHREF)-1) & '/index.cfm/'>
							<cfelse>
								<cfset baseHREF = "index.cfm/">
							</cfif>

							<base href="#baseHREF#" />
						</cfif>

					  <link rel="shortcut icon" type="image/png" href="/node_modules/jasmine-core/images/jasmine_favicon.png">
					  <link rel="stylesheet" href="/node_modules/jasmine-core/lib/jasmine-core/jasmine.css">

					  <script type="text/javascript" src="/node_modules/jasmine-core/lib/jasmine-core/jasmine.js"></script>
						<cfif structKeyExists(url,'phantomJS')>
							<script src="/node_modules/jasmine-core/lib/jasmine-core/jasmine-html.js"></script>
							<script type="text/javascript" src="/node_modules/jasmine-core/lib/console/console.js"></script>

						<cfelse>
							<script src="/node_modules/jasmine-core/lib/jasmine-core/jasmine-html.js"></script>
						</cfif>



					  <!-- include source files here... -->
					  <script type="text/javascript" src="#request.slatwallScope.getBaseURL()#/org/Hibachi/HibachiAssets/js/jquery-1.7.1.min.js"></script>
						<script type="text/javascript" src="#request.slatwallScope.getBaseURL()#/org/Hibachi/HibachiAssets/js/jquery-ui.min.js"></script>
						<script type="text/javascript" src="#request.slatwallScope.getBaseURL()#/org/Hibachi/HibachiAssets/js/jquery-validate-1.9.0.min.js"></script>
						<script type="text/javascript" src="#request.slatwallScope.getBaseURL()#/org/Hibachi/HibachiAssets/js/bootstrap.min.js"></script>

						#request.slatwallScope.renderJSObject()#
						<script type="text/javascript">
							var hibachiConfig = $.slatwall.getConfig();
							hibachiConfig.baseURL = '/';
						</script>
						<script type="text/javascript" src="#request.slatwallScope.getBaseURL()#/assets/js/admin.js?instantiationKey=#$.slatwall.getApplicationValue('instantiationKey')#"></script>

						<script src='https://www.google.com/recaptcha/api.js'></script>

					  <!--<script type="text/javascript" src="#request.slatwallScope.getBaseURL()#/org/Hibachi/HibachiAssets/js/global.js?instantiationKey=#$.slatwall.getApplicationValue('instantiationKey')#"></script>
-->
					  <!-- include spec files here... -->

					</head>

					<body>

						<script type="text/javascript" src="#request.slatwallScope.getBaseURL()#/admin/client/src/testbundle.js?instantiationKey=#$.slatwall.getApplicationValue('instantiationKey')#" charset="utf-8"></script>
						<script type="text/javascript">
						 // var console_reporter = new getJasmineRequireObj().ConsoleReporter(console.log)
						 // jasmine.getEnv().addReporter(new getJasmineRequireObj().TrivialReporter());
						  //jasmine.getEnv().addReporter(console_reporter);

						  //jasmine.getEnv().addReporter(new jasmine.ConsoleReporter(console.log));
						  //jasmine.getEnv().execute();

						</script>
						<script type="text/javascript">
							var ConsoleReporter = jasmineRequire.ConsoleReporter();
							var options = {
								timer: new jasmine.Timer,
								print: function () {
										console.log.apply(console,arguments)
							}};
							consoleReporter = new ConsoleReporter(options); // initialize ConsoleReporter
							jasmine.getEnv().addReporter(consoleReporter);
							</script>
					</body>
				</html>
			</cfoutput>
		</cfsavecontent>
		<cfscript>
			writeoutput(local.specrunnerOutput);abort;
		</cfscript>

	</cffunction>

</cfcomponent>