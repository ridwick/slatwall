'use strict';
angular.module('slatwalladmin')
.directive('swFormRegistrar', 
[
	'formService',
	function(formService){
		return {
			restrict: 'E',
			require:"^form",
			link: function(scope, element,attrs,formController){
				/*add form info at the form level*/
				formController.$$swFormInfo={
					object:scope.object,
					context:scope.context,
					name:scope.name
				};
				scope.form = formController;
				/*register form with service*/
				formController.name = scope.name
				formService.setForm(formController);
				
				/*register form at object level*/
				if(angular.isUndefined(scope.object.forms)){
					scope.object.forms = {};
				}
				console.log('formName');
				console.log(scope.name);
				scope.object.forms[scope.name] = formController;
				
				/*if a context is supplied at the form level, then decorate the inputs with client side validation*/
				if(angular.isDefined(scope.context)){
					
				}
			}
		};
	}
]);
	
