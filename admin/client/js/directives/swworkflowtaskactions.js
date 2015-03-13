angular.module('slatwalladmin')
    .directive('swWorkflowTaskActions', [
        '$log',
        '$slatwall',
        'metadataService',
        'collectionService',
        'workflowPartialsPath',
        function (
            $log,
            $slatwall,
            metadataService,
            collectionService,
            workflowPartialsPath
        ) {
            return {
                restrict: 'AE',
                scope: {
                    workflowTask: "="
                },
                templateUrl: workflowPartialsPath + "workflowtaskactions.html",
                link: function (scope, element, attrs) {
                    $log.debug('Workflow Task Actions Init');
                    $log.debug(scope.workflowTask);
                    scope.openActions = false;

                    var getObjectByActionType = function (workflowTaskAction) {
                        if (workflowTaskAction.data.actionType === 'email') {
                            workflowTaskAction.$$getEmailTemplate();
                        } else if (workflowTaskAction.data.actionType === 'print') {
                            workflowTaskAction.$$getPrintTemplate();
                        }
                    };
                    /**
                     * --------------------------------------------------------------------------------------------------------
                     * Returns workflow task action, and saves them to the scope variable workflowtaskactions
                     * --------------------------------------------------------------------------------------------------------
                     */
                    scope.getWorkflowTaskActions = function () {
                        var workflowTaskPromise = scope.workflowTask.$$getWorkflowTaskActions();
                        workflowTaskPromise.then(function () {
                            scope.workflowTaskActions = scope.workflowTask.data.workflowTaskActions;

                            angular.forEach(scope.workflowTaskActions, function (workflowTaskAction) {
                                getObjectByActionType(workflowTaskAction);
                            });
                            $log.debug(scope.workflowTaskActions);
                        });
                        if (angular.isUndefined(scope.workflowTask.data.workflowTaskActions)) {
                            scope.workflowTask.data.workflowTaskActions = [];
                            scope.workflowTaskActions = scope.workflowTask.data.workflowTaskActions;
                        }
                    };
                    

                    /**
                     * --------------------------------------------------------------------------------------------------------
                     * Saves the workflow task actions by calling the objects $$save method.
                     * @param taskAction
                     * --------------------------------------------------------------------------------------------------------
                     */
                    scope.saveWorkflowTaskAction = function (taskAction) {
                        $log.debug("saving task action and parent task");
                        $log.debug(taskAction);
                        var savePromise = scope.workflowTaskActions.selectedTaskAction.$$save();
                        savePromise.then(function () {
                            var taSavePromise = taskAction.$$save;
                        });
                        scope.selectWorkflowTaskAction(taskAction); //Was selecting after save trying to get it to work!!! Not working.

                    }

                    scope.getWorkflowTaskActions();//Call get
                    
                    /**
                     * --------------------------------------------------------------------------------------------------------
                     * Adds workflow action items by calling the workflowTask objects $$addWorkflowTaskAction() method
                     * and sets the result to scope.
                     * @param taskAction
                     * --------------------------------------------------------------------------------------------------------
                     */
                    scope.addWorkflowTaskAction = function (taskAction) {
                        var workflowTaskAction = scope.workflowTask.$$addWorkflowTaskAction();
                        scope.selectWorkflowTaskAction(workflowTaskAction);
                        $log.debug(scope.workflow);
                    };
                    
                    /**
                     * --------------------------------------------------------------------------------------------------------
                     * Selects a new task action and populates the task action properties.
                     * --------------------------------------------------------------------------------------------------------
                     */
                    scope.selectWorkflowTaskAction = function (workflowTaskAction) {
                        $log.debug("Selecting new task action: ");
                        $log.debug(workflowTaskAction);
                        scope.workflowTaskActions.selectedTaskAction = undefined;
                        var filterPropertiesPromise = $slatwall.getFilterPropertiesByBaseEntityName(scope.workflowTask.data.workflow.data.workflowObject);
                        filterPropertiesPromise.then(function (value) {
                            scope.filterPropertiesList = {
                                baseEntityName: scope.workflowTask.data.workflow.data.workflowObject,
                                baseEntityAlias: "_" + scope.workflowTask.data.workflow.data.workflowObject
                            };
                            metadataService.setPropertiesList(value, scope.workflowTask.data.workflow.data.workflowObject);
                            scope.filterPropertiesList[scope.workflowTask.data.workflow.data.workflowObject] = metadataService.getPropertiesListByBaseEntityAlias(scope.workflowTask.data.workflow.data.workflowObject);
                            metadataService.formatPropertiesList(scope.filterPropertiesList[scope.workflowTask.data.workflow.data.workflowObject], scope.workflowTask.data.workflow.data.workflowObject);
                            scope.workflowTaskActions.selectedTaskAction = workflowTaskAction;
                        });
                        //scope.workflowTaskActions.selectedTaskAction = workflowTaskAction;
                    };

                    /**
                     * --------------------------------------------------------------------------------------------------------
                     * Removes a workflow task action by calling the selected tasks $$delete method
                     * and reindexes the list.
                     * --------------------------------------------------------------------------------------------------------
                     */
                    scope.removeWorkflowTaskAction = function (workflowTaskAction) {
                        var deletePromise = workflowTaskAction.$$delete();
                        deletePromise.then(function () {
                            if (workflowTaskAction === scope.workflowTaskActions.selectedTaskAction) {
                                delete scope.workflowTaskActions.selectedTaskAction;
                            }
                            $log.debug("removeWorkflowTaskAction");
                            $log.debug(workflowTaskAction);
                            scope.workflowTaskActions.splice(workflowTaskAction.$$actionIndex, 1);
                            for (var i in scope.workflowTaskActions) {
                                scope.workflowTaskActions[i].$$actionIndex = i;
                            }
                        });
                    };
                }
            };
        }
    ]);