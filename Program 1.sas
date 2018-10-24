sap.ui.define([

   "jquery.sap.global",

    "sap/ui/core/mvc/JSView",

    "sap/ui/core/ResizeHandler",

    "sap/ui/commons/layout/BorderLayout",

    "sap/ui/commons/layout/BorderLayoutArea",

    "sap/ui/commons/layout/BorderLayoutAreaTypes",

    "sas/sasstudio/view/components/JSComponentView",

    "sas/sasstudio/services/ViewServices",

    "sas/sasstudio/services/BindingUtils",

    "sas/sasstudio/services/StudioUtils",

    "sas/hc/ui/commons/layout/MatrixLayout",

    "sas/hc/m/Text",

    "sas/hc/m/Input",

    "sas/hc/m/Select",

    "sas/hc/ui/commons/RichTooltip",

    "sas/hc/m/CompositeInput",

    "sas/sasstudio/model/TabObjectTypes",

    "sas/sasstudio/commons/components/SelectColumnDialog",

    "sas/hc/ui/commons/layout/VerticalLayout",

    "sas/hc/m/ResponsivePopover",

    "sap/m/ListSeparators",

    "sas/hc/m/List",

    "sas/hc/m/StandardListItem",

    "sas/hc/ui/unified/Menu",

	"sas/hc/ui/unified/MenuItem",

    "sas/hc/ui/commons/codeEditor/CodeEditor",

    "sas/sasstudio/view/components/query/QueryViewUtils",

], function (jQuery, JSView, ResizeHandler, BorderLayout, BorderLayoutArea, BorderLayoutAreaTypes, JSComponentView, ViewServices,

    BindingUtils, StudioUtils, MatrixLayout, Text, Input, Select, RichTooltip, CompositeInput,

    TabObjectTypes, SelectColumnDialog, VerticalLayout, ResponsivePopover, ListSeparators, List, StandardListItem,

    Menu, MenuItem, CodeEditor, QueryViewUtils) {



    sas.sasstudio.jscomponentview("sas.sasstudio.view.components.query.Join", {



        sModuleName: "Join.view.js",



        ////////////////////////////////////////////////////////////////////////////////////////////

        // Helpers



        getTextView: function () {

            return this.oTextView;

        },



        getControllerName: function () {

            return "sas.sasstudio.controller.components.query.Join";

        },



        getMainAreaID: function () {

            return this.sMainAreaID;

        },



        setMainAreaID: function (sValue) {

            this.sMainAreaID = sValue;

        },



        getPanelAreaID: function () {

            return this.sPanelAreaID;

        },



        setPanelAreaID: function (sValue) {

            this.sPanelAreaID = sValue;

        },



        // Called when the tab for this view is closed

        onClose: function () {

            this.destroy();

        },



        ////////////////////////////////////////////////////////////////////////////////////////////

        // Content



        createContent: function (oController) {



            this.oController = oController;



            var aControls = [];

            var oJoinSelectLists = [];

            this.oJoinSelectLists = oJoinSelectLists;



            this.oMainLayout = new BorderLayout(this.createId("mainLayout"), {

                width: "100%", height: "100%",

            });



            var editButton = ViewServices.createToolbarIconTextButton(oController.createId("expressionBuilderEditorAddButton"), {

                text: "{i18n>queryJoinEditExpression.txt}",

                icon: sas.icons.HC.EDIT

            });

            editButton.attachPress(jQuery.proxy(oController.onEditExpression, oController, jQuery.proxy(this.applyEditExpression, this, oController)));

            this.editButton = editButton;



            var resetButton = ViewServices.createToolbarIconTextButton(oController.createId("resetButton"), {

                text: "Reset Joins",

                icon: sas.icons.HC.RESET

            });

            resetButton.attachPress(jQuery.proxy(oController.onResetJoins, oController));

            resetButton.setEnabled(false);

            this.resetButton = resetButton;





            // add the editor toolbar to the TOP AREA of the BorderLayout

            var expressionToolbar = ViewServices.createToolbar();



            // Add edit button to the toolbar

            expressionToolbar.addContent(editButton);

            expressionToolbar.addContent(resetButton);



            var expressionBuilderEditorTopArea = this.oMainLayout.createArea(BorderLayoutAreaTypes.top, expressionToolbar);

            this.oMainLayout.setAreaData(BorderLayoutAreaTypes.top, {

                size: ViewServices.toolbarHeight,

                overflowX: "hidden",

                overflowY: "hidden",

                visible: true

            });



            var hasMoreThanOneTable = false; // TODO



            this.rowsJoinMatrixLayout = this.createJoinMatrixLayout(oController);

            this.oZeroStateJoinMatrixLayout = this.createZeroStateJoinMatrixLayout(oController);



            if (hasMoreThanOneTable) {

                this.oJoinMatrixLayout = this.rowsJoinMatrixLayout;

            } else {

                this.oJoinMatrixLayout = this.oZeroStateJoinMatrixLayout;

            }



            this.oCenterArea = this.oMainLayout.createArea(BorderLayoutAreaTypes.center, this.oJoinMatrixLayout);

            this.oMainLayout.setAreaData(BorderLayoutAreaTypes.center, {

                size: "100%",

                overflowX: "hidden",

                overflowY: "auto",

                visible: true

            });



            aControls.push(this.oMainLayout);



            return aControls;

        },



        createCenterAreaView: function (oController) {



            var hasMoreThanOneTable = false; // TODO



            this.rowsJoinMatrixLayout = this.createJoinMatrixLayout(oController);

            this.oZeroStateJoinMatrixLayout = this.createZeroStateJoinMatrixLayout(oController);



            if (hasMoreThanOneTable) {

                this.oJoinMatrixLayout = this.rowsJoinMatrixLayout;

            } else {

                this.oJoinMatrixLayout = this.oZeroStateJoinMatrixLayout;

            }



            var centerArea = new sap.ui.commons.layout.BorderLayoutArea({

                height: "100%",

                width: "100%",

                visible: true,

                overflowX: "hidden",

                overflowY: "auto",

                content: [this.oJoinMatrixLayout]

            });



            this.oCenterArea = centerArea;



            return centerArea;

        },



        createZeroStateJoinMatrixLayout: function (oController) {



            var oImage4 = new sas.hc.ui.commons.Image({

                src: sas.icons.HC.ZEROSTATEADD,

                width: "150px",

                height: "53px"

            });

            var oInitialSelectText = new sas.hc.m.Text({

                id: this.createId("initialSelectText"),

                text: "{i18n>queryZeroStateJoinText.txt}"

            });



            var zeroStateVbox = new sas.hc.m.VBox({

                height: "100%",

                items: [

    	                oImage4,

    	                oInitialSelectText

                ]

            });



            zeroStateVbox.setAlignItems("Center");

            zeroStateVbox.setJustifyContent("Center");



            return zeroStateVbox;



        },



        createJoinMatrixLayout: function (oController) {



            var oJoinMatrixLayout = new MatrixLayout({

                columns: 5, width: "100%",

            });

            oJoinMatrixLayout.setWidths(["100%", "32px", "100%", "32px", "32px"]);

            this.oJoinMatrixLayout = oJoinMatrixLayout;



            oJoinMatrixLayout.addDelegate({

                onAfterRendering: $.proxy(function (oControl, oController) {

                    var layoutDomNode = oControl.getDomRef();



                    jQuery(layoutDomNode).on('mouseleave', jQuery.proxy(function (e) {

                        return this.onJoinMatrixLayoutMouseLeave(e);

                    }, this));



                }, this, oJoinMatrixLayout, oController)

            });



            return oJoinMatrixLayout;

        },



        showExpressionEditor: function (code, callback) {

            this.oController.showEditExpressionEditor(code, callback);

        },



        applyEditExpression: function (oController) {



            var filter = this.oController.oData.getJoinFormattedFilter();

            this.oMainView.generateSQL();



            this.oCenterArea.removeAllContent();



            this.resetButton.setEnabled(true);

            var settings = QueryViewUtils.getCodeEditorSettings();

            this.joinBuilderEditor = new CodeEditor(this.createId("joinBuilderEditor"), settings);



            this.joinBuilderEditor.activate();

            this.joinBuilderEditor.focus();

            this.joinBuilderEditor.addStyleClass("stretchContentLayout");

            this.joinBuilderEditor.resize('100%', '100%');

            this.joinBuilderEditor.setText(filter);



            this.joinBuilderEditor.addDelegate({

                onAfterRendering: $.proxy(function (oControl) {

                    var domNode = oControl.getDomRef();

                    if (domNode) {

                        jQuery(domNode).on('mouseleave', jQuery.proxy(function (e) {

                            return this.onEditorMouseleave(e);

                        }, this));

                        $(domNode).css("overflow", "hidden");

                    }



                    var dView = this;

                    var dnd = new sas.sasstudio.commons.DnDHelper();

                    $(domNode).droppable({

                        greedy: true,

                        tolerance: "pointer",

                        drop: function (event, ui) {

                            QueryViewUtils.handleDropOnEditor(event, ui, dView);

                        },

                        out: function (event, ui) {

                            StudioUtils.stopPropagation(event);

                            DnDHelper.getInstance().addDropClass(null, 'N');

                        },

                        over: jQuery.proxy(function (event, ui) {

                            var canDrop = QueryViewUtils.canDropOnEditor(event, ui);

                            if (canDrop) {

                                DnDHelper.getInstance().addDropClass($(this)[0].id, 'I');

                            }

                        }, this)

                    });



                    oControl.focus();



                }, this, this.joinBuilderEditor)

            });



            this.oCenterArea.addContent(this.joinBuilderEditor);

        },



        onEditorMouseleave: function (e) {

            if (this.oController.oData.getJoinFormattedFilter() !== this.joinBuilderEditor.getText()) {

                this.oController.oData.setJoinFormattedFilter(this.joinBuilderEditor.getText());

                this.oMainView.generateSQL();

            }

        },



        // swap between the zero state and join matrix when the query has more than one table

        swapJoinLayoutMatrix: function (hasMoreThanOneTable) {



            var content = this.oMainLayout.getContent(BorderLayoutAreaTypes.center)[0];



            if (hasMoreThanOneTable) {

                if (!content || content !== this.rowsJoinMatrixLayout) {

                    this.oMainLayout.removeAllContent(BorderLayoutAreaTypes.center);

                    this.oMainLayout.addContent(BorderLayoutAreaTypes.center, this.rowsJoinMatrixLayout);

                    this.oJoinMatrixLayout = this.rowsJoinMatrixLayout;

                }

            } else {

                if (!content || content !== this.oZeroStateJoinMatrixLayout) {

                    this.oMainLayout.removeAllContent(BorderLayoutAreaTypes.center);

                    this.oMainLayout.addContent(BorderLayoutAreaTypes.center, this.oZeroStateJoinMatrixLayout);

                    this.oJoinMatrixLayout = this.oZeroStateJoinMatrixLayout;

                }

            }

        },



        onJoinMatrixLayoutMouseLeave: function (e) {



            var content = this.oMainLayout.getContent(BorderLayoutAreaTypes.center)[0];



            if (!content || content !== this.rowsJoinMatrixLayout) {

                return;

            }



            var rows = this.oJoinMatrixLayout.getRows();



            for (var i = 0; i < rows.length; i++) {

                targetRow = rows[i];



                var cells = targetRow.getCells();

                if (cells.length === 5) {

                    var buttonChangeType = cells[1].getContent();

                    var buttonAdd = cells[4].getContent();

                    var buttonDelete = cells[3].getContent();

                    buttonAdd[0].setVisible(false);

                    buttonDelete[0].setVisible(false);

                    if (buttonChangeType[0].hasStyleClass("queryRowHighlighted")) {

                        buttonChangeType[0].removeStyleClass("queryRowHighlighted");

                    }

                    buttonChangeType[0].addStyleClass("queryRowNormal");

                    if (targetRow.hasStyleClass("queryRowHighlighted")) {

                        targetRow.removeStyleClass("queryRowHighlighted");

                        targetRow.addStyleClass("queryRowNormal");

                    }

                }

            }

        },



        addRowControlHighlightDelegates: function (oControl) {

            oControl.addDelegate({

                onAfterRendering: $.proxy(function (oControl) {

                    var domNode = oControl.getDomRef();



                    jQuery(domNode).on('mouseover', jQuery.proxy(function (e) {

                        var targetId = e.currentTarget.id;

                        var sendingControl = sap.ui.getCore().byId(targetId);

                        var highlightId = sendingControl.oParent.oParent.sId;

                        this.onJoinRowMouseIn(highlightId);

                    }, this));



                    jQuery(domNode).on('mouseleave', jQuery.proxy(function (e) {

                        var targetId = e.currentTarget.id;

                        var sendingControl = sap.ui.getCore().byId(targetId);

                        var highlightId = sendingControl.oParent.oParent.sId;

                        this.onJoinRowMouseOut(highlightId);

                    }, this));



                }, this, oControl)

            });

        },



        onJoinRowMouseIn: function (uniqueRowId) {



            var content = this.oMainLayout.getContent(BorderLayoutAreaTypes.center)[0];



            if (!content || content !== this.rowsJoinMatrixLayout) {

                return;

            }



            var rows = this.oJoinMatrixLayout.getRows();

            var targetRow;



            for (var i = 0; i < rows.length; i++) {

                if (rows[i].sId === uniqueRowId) {



                    var firstRow = false;

                    if (this.lastRowId === undefined) {

                        this.lastRowId = uniqueRowId;

                        firstRow = true;

                    }



                    targetRow = rows[i];



                    var cells = targetRow.getCells();

                    if (cells.length === 5) {

                        var buttonChangeType = cells[1].getContent();

                        var buttonAdd = cells[4].getContent();

                        var buttonDelete = cells[3].getContent();

                        if (buttonChangeType[0].hasStyleClass("queryRowNormal")) {

                            buttonChangeType[0].removeStyleClass("queryRowNormal");

                        }

                        buttonChangeType[0].addStyleClass("queryRowHighlighted");

                        buttonAdd[0].setVisible(true);



                        if (!uniqueRowId.includes("primaryConditionRowId")) {

                            buttonDelete[0].setVisible(true);

                        }



                        if (targetRow.hasStyleClass("queryRowNormal")) {

                            targetRow.removeStyleClass("queryRowNormal");

                        }

                        targetRow.addStyleClass("queryRowHighlighted");

                        break;

                    }

                }                

            }



            for (var i = 0; i < rows.length; i++) {



                if (rows[i].sId !== uniqueRowId) {



                    targetRow = rows[i];

                    if (targetRow.hasStyleClass("queryRowNormal")) {

                        // anything need to be done here?

                    }

                    else {

                        var cells = targetRow.getCells();

                        if (cells.length === 5) {

                            var buttonChangeType = cells[1].getContent();

                            var buttonAdd = cells[4].getContent();

                            var buttonDelete = cells[3].getContent();

                            if (buttonChangeType[0].hasStyleClass("queryRowHighlighted")) {

                                buttonChangeType[0].removeStyleClass("queryRowHighlighted");

                            }

                            buttonChangeType[0].addStyleClass("queryRowNormal");

                            buttonAdd[0].setVisible(false);

                            buttonDelete[0].setVisible(false);



                            if (targetRow.hasStyleClass("queryRowHighlighted")) {

                                targetRow.removeStyleClass("queryRowHighlighted");

                                targetRow.addStyleClass("queryRowNormal");

                            }

                        }

                    }

                }

            }            

        },



        onJoinRowMouseOut: function (uniqueRowId) {

            // look to see if this is where we need to turn off the highlight if

            // the mouse exits to the RIGHT of a row...

        },



        createJoinGroup: function (join, isFirstGroup) {

            //debugger;

            var joinNumber = 0;

            // find the join in the QueryObject to figure out which join it is...Join 1, Join 2, Join 3, etc...

            for (var i = 0; i < this.oController.oData.getQueryJoins().length; i++) {



                var testJoin = this.oController.oData.getQueryJoins()[i];

                if (testJoin.id === join.id) {

                    // this is the join, remember the index so that we can write the appropriate titles

                    joinNumber = i + 1;

                    break;

                }

            }



            var joinLeftString = null;

            var joinRightString = null;

            if (join.leftTable !== null) {

                joinLeftString = "(" + join.leftTable.alias + ") " + join.leftTable.libname + "." + join.leftTable.member;

            }

            joinRightString = "(" + join.rightTable.alias + ") " + join.rightTable.libname + "." + join.rightTable.member;

            var joinText = "Join " + joinNumber;



            // ############################ create a title row for the new join

            var titleRowId = this.createId("titleRowId");



            var text1 = new sas.hc.m.Text({

                id: titleRowId,

                text: joinText

            }).addStyleClass("querySelectHeaderText");

            this.addRowControlHighlightDelegates(text1);



            oTitleCell = new sap.ui.commons.layout.MatrixLayoutCell();

            oTitleCell.addContent(text1);



            var oTitleRow = new sap.ui.commons.layout.MatrixLayoutRow({

                id: this.createId("rowHeader"),

                height: '35px'

            });



            oTitleRow.addCell(oTitleCell);



            var titleRowData = ["Title Row", join];

            oTitleRow.data("rowData", titleRowData);



            this.oJoinMatrixLayout.addRow(oTitleRow);



            // ############################ create a row for the table drop downs

            var joinRowId = this.createId("joinTableRowId");



            var oPrimaryTableSelect = new sas.hc.m.Select({

                width: "100%",

                displayListItemIcon: true

            });





            var leftTableItem = new sas.hc.ui.core.Item({

                key: joinLeftString,

                tooltip: joinLeftString,

                text: joinLeftString

            });

            oPrimaryTableSelect.addItem(leftTableItem);



            var joinResultText = "Results from Join " + (joinNumber - 1);



            var text2 = new sas.hc.m.Text({

                id: this.createId("text2"),

                text: joinResultText

            });

            text2.setVisible(false);

            this.addRowControlHighlightDelegates(text2);



            if (this.oController.oData.getQueryJoins().length > 1) {

                oPrimaryTableSelect.setVisible(false);

                text2.setVisible(true);

            }

            else {

                this.oPrimaryTableSelect = oPrimaryTableSelect;

            }



            var joinTypeParms = [joinRowId, join];

            var oJoinTypeButton = ViewServices.createToolbarIconMenuButton50(this.createId("joinTypeButton"), {

                icon: sas.icons.HC.VENNDIAGRAMAND,

                menu: this.createJoinTypeMenu(joinTypeParms),

                tooltip: "{i18n>queryInnerJoin.txt}"

            });

            oJoinTypeButton.setVisible(true);

            this.oJoinTypeButton = oJoinTypeButton;



            // NOTE: All of these join type buttons are in here to receive a translated string.  It seems that they

            // can't be changed dynamically in the event handler itself...if you try to directly reference something like

            // {i18n>queryInnerJoin.txt} in the event handler when it wasn't rendered to begin with all you seem to get is

            // "{i18n>queryInnerJoin.txt}".  Keeping these extra invisible buttons gets the string translated and into existence

            // correctly where it can then be swapped appropriately in the event handler

            // http://sww.sas.com/defects/java/iDefects/WebClient.html?defectid=S1441292

            // This can be changed if there is a different control or better way of doing this that I wasn't aware of...miburk

            var oJoinTypeInnerButton = ViewServices.createToolbarIconMenuButton50(this.createId("joinTypeButton"), {

                icon: sas.icons.HC.VENNDIAGRAMAND,

                menu: this.createJoinTypeMenu(joinTypeParms),

                tooltip: "{i18n>queryInnerJoin.txt}"

            });

            oJoinTypeInnerButton.setVisible(false);

            var oJoinTypeLeftButton = ViewServices.createToolbarIconMenuButton50(this.createId("joinTypeButton"), {

                icon: sas.icons.HC.VENNDIAGRAMLEFTJOIN,

                menu: this.createJoinTypeMenu(joinTypeParms),

                tooltip: "{i18n>queryLeftJoin.txt}"

            });

            oJoinTypeLeftButton.setVisible(false);

            var oJoinTypeRightButton = ViewServices.createToolbarIconMenuButton50(this.createId("joinTypeButton"), {

                icon: sas.icons.HC.VENNDIAGRAMRIGHTJOIN,

                menu: this.createJoinTypeMenu(joinTypeParms),

                tooltip: "{i18n>queryRightJoin.txt}"

            });

            oJoinTypeRightButton.setVisible(false);

            var oJoinTypeOuterButton = ViewServices.createToolbarIconMenuButton50(this.createId("joinTypeButton"), {

                icon: sas.icons.HC.VENNDIAGRAMCROSSJOIN,

                menu: this.createJoinTypeMenu(joinTypeParms),

                tooltip: "{i18n>queryOuterJoin.txt}"

            });

            oJoinTypeOuterButton.setVisible(false);



            var oSecondaryTableSelect = new sas.hc.m.Select({

                width: "100%",

                displayListItemIcon: true

            });

            var rightTableItem = new sas.hc.ui.core.Item({

                key: joinRightString,

                tooltip: joinRightString,

                text: joinRightString

            });

            oSecondaryTableSelect.addItem(rightTableItem);



            oPrimaryTableCell = new sap.ui.commons.layout.MatrixLayoutCell();

            oJoinTypeCell = new sap.ui.commons.layout.MatrixLayoutCell();

            oSecondaryTableCell = new sap.ui.commons.layout.MatrixLayoutCell();



            var tableRowTypeDesc = "Table Row 1";

            if (this.oController.oData.getQueryJoins().length > 1) {

                tableRowTypeDesc = "Table Row 2";

                oPrimaryTableCell.addContent(text2);

            }

            else {

                tableRowTypeDesc = "Table Row 1";

                oPrimaryTableCell.addContent(oPrimaryTableSelect);



                var selectAndJoinPrimary = [join, oPrimaryTableSelect];

                this.oJoinSelectLists.push(selectAndJoinPrimary)

            }



            oJoinTypeCell.addContent(oJoinTypeButton);

            oJoinTypeCell.addContent(oJoinTypeInnerButton);

            oJoinTypeCell.addContent(oJoinTypeLeftButton);

            oJoinTypeCell.addContent(oJoinTypeRightButton);

            oJoinTypeCell.addContent(oJoinTypeOuterButton);



            oSecondaryTableCell.addContent(oSecondaryTableSelect);

            var selectAndJoinSecondary = [join, oSecondaryTableSelect];

            this.oJoinSelectLists.push(selectAndJoinSecondary)



            var oTableJoinRow = new sap.ui.commons.layout.MatrixLayoutRow({

                id: joinRowId,

                height: '45px'

            });



            oTableJoinRow.addCell(oPrimaryTableCell);

            oTableJoinRow.addCell(oJoinTypeCell);

            oTableJoinRow.addCell(oSecondaryTableCell);



            var tableRowData = [tableRowTypeDesc, join];

            oTableJoinRow.data("rowData", tableRowData);

            this.rowsJoinMatrixLayout.addRow(oTableJoinRow);



            // ############################ create a row for the primary condition

            var conditionRowId = this.createId("primaryConditionRowId");



            var oLeftConditionCompositeInput = new sas.hc.m.CompositeInput({

                id: this.createId("leftConditionCompositeInput"),

                inputProperties: {

                    type: sap.m.InputType.Text,

                    editable: false,

                    tooltip: "",

                    value: ""

                },

                buttonProperties: {

                    icon: sas.icons.HC.COLUMN,

                    tooltip: ""

                }

            });

            var leftInputValue = "";

            var leftTableAlias = "";

            var leftColumn = "";

            if (join.leftTable !== null) {

                leftInputValue = join.leftTable.alias + "." + join.leftTable.data.columns[0].name;

                leftTableAlias = join.leftTable.alias;

                leftColumn = join.leftTable.data.columns[0].name;

            }

            else {

                // go look for the default in the first join left table

                leftInputValue = this.oController.oData.getQueryJoins()[0].leftTable.alias + "." + this.oController.oData.getQueryJoins()[0].leftTable.data.columns[0].name;

                leftTableAlias = this.oController.oData.getQueryJoins()[0].leftTable.alias;

                leftColumn = this.oController.oData.getQueryJoins()[0].leftTable.data.columns[0].name;

            }

            var rightTableAlias = join.rightTable.alias;

            var rightColumn = join.rightTable.data.columns[0].name;



            var conditionId = this.createGUID();

            var newCondition =

                {

                    id: conditionId,

                    leftTableAlias: leftTableAlias,

                    leftColumn: leftColumn,

                    operator: "=",

                    rightTableAlias: rightTableAlias,

                    rightColumn: rightColumn

                };

            join.conditions.push(newCondition);



            this.oController.oData.updateQueryJoin(join);



            var leftInputField = oLeftConditionCompositeInput.getAggregation("input");

            leftInputField.setValue(leftInputValue);



            var thisView = this;



            oLeftConditionCompositeInput.attachPress($.proxy(function (oEvent) {



                var tables = null;

                if (!isFirstGroup){

                    tables = this.oController.oData.getQueryTables();

                }

                else{

                    tables = [this.oController.oData.getQueryTables()[0]];

                }

                            

                var useLabels = QueryViewUtils.getUseLabels();



                SelectColumnDialog.show(tables, useLabels, function (table, colObject) {



                    console.log("ok clicked table = " + table.alias + " column = " + colObject.name);

                    leftInputField.setValue(table.alias + "." + colObject.name);



                    newCondition.leftTableAlias = table.alias;

                    newCondition.leftColumn = colObject.name;



                    for (var i = 0; i < join.conditions.length; i++) {

                        if (join.conditions[i].id === newCondition.id) {

                            join.conditions[i].leftTableAlias = newCondition.leftTableAlias;

                            join.conditions[i].leftColumn = newCondition.leftColumn;

                            break;

                        }

                    }

                    thisView.oController.oData.updateQueryJoin(join);

                    thisView.oMainView.generateSQL();



                });

            }, this));



            var operatorData = [conditionRowId, join, newCondition];

            var oOperatorButton = ViewServices.createToolbarIconMenuButton50(this.createId("operatorButton"), {

                icon: sas.icons.HC.OPERATOREQUAL,

                menu: this.createOperatorMenu(operatorData),

                tooltip: "{i18n>queryIsEqualTo.txt}",

            }).addStyleClass("queryJoinOperatorButton");

            oOperatorButton.setVisible(true);



            // NOTE: All of these operator type buttons are in here to receive a translated string.  It seems that they

            // can't be changed dynamically in the event handler itself...if you try to directly reference something like

            // {i18n>queryInnerJoin.txt} in the event handler when it wasn't rendered to begin with all you seem to get is

            // "{i18n>queryInnerJoin.txt}".  Keeping these extra invisible buttons gets the string translated and into existence

            // correctly where it can then be swapped appropriately in the event handler

            // http://sww.sas.com/defects/java/iDefects/WebClient.html?defectid=S1441292

            // This can be changed if there is a different control or better way of doing this that I wasn't aware of...miburk

            var oOperatorEqualToButton = ViewServices.createToolbarIconMenuButton50(this.createId("operatorButton"), {

                tooltip: "{i18n>queryIsEqualTo.txt}",

            }).addStyleClass("queryJoinOperatorButton");

            oOperatorEqualToButton.setVisible(false);

            var oOperatorIsNotEqualToButton = ViewServices.createToolbarIconMenuButton50(this.createId("operatorButton"), {

                tooltip: "{i18n>queryIsNotEqualTo.txt}",

            }).addStyleClass("queryJoinOperatorButton");

            oOperatorIsNotEqualToButton.setVisible(false);

            var oOperatorIsLessThanButton = ViewServices.createToolbarIconMenuButton50(this.createId("operatorButton"), {

                tooltip: "{i18n>queryIsLessThan.txt}",

            }).addStyleClass("queryJoinOperatorButton");

            oOperatorIsLessThanButton.setVisible(false);

            var oOperatorIsLessThanOrEqualToButton = ViewServices.createToolbarIconMenuButton50(this.createId("operatorButton"), {

                tooltip: "{i18n>queryIsLessThanOrEqualTo.txt}",

            }).addStyleClass("queryJoinOperatorButton");

            oOperatorIsLessThanOrEqualToButton.setVisible(false);

            var oOperatorIsGreaterThanButton = ViewServices.createToolbarIconMenuButton50(this.createId("operatorButton"), {

                tooltip: "{i18n>queryIsGreaterThan.txt}",

            }).addStyleClass("queryJoinOperatorButton");

            oOperatorIsGreaterThanButton.setVisible(false);

            var oOperatorIsGreaterThanOrEqualToButton = ViewServices.createToolbarIconMenuButton50(this.createId("operatorButton"), {

                tooltip: "{i18n>queryIsGreaterThanOrEqualTo.txt}",

            }).addStyleClass("queryJoinOperatorButton");

            oOperatorIsGreaterThanOrEqualToButton.setVisible(false);



            var oRightConditionCompositeInput = new sas.hc.m.CompositeInput({

                id: this.createId("leftConditionCompositeInput"),

                inputProperties: {

                    type: sap.m.InputType.Text,

                    editable: false,

                    tooltip: "",

                    value: ""

                },

                buttonProperties: {

                    icon: sas.icons.HC.COLUMN,

                    tooltip: ""

                }

            });



            // TODO: search for best column match, not just the first column

            var rightInputValue = join.rightTable.alias + "." + join.rightTable.data.columns[0].name;



            var rightInputField = oRightConditionCompositeInput.getAggregation("input");

            rightInputField.setValue(rightInputValue);



            oRightConditionCompositeInput.attachPress($.proxy(function (oEvent) {

                join.rightTable.data.type = "DATA";

                var tables = [join.rightTable];

                var useLabels = QueryViewUtils.getUseLabels();

                SelectColumnDialog.show(tables, useLabels, function (table, colObject) {

                    console.log("ok clicked table = " + table.alias + " column = " + colObject.name);

                    rightInputField.setValue(table.alias + "." + colObject.name);



                    newCondition.rightTableAlias = table.alias;

                    newCondition.rightColumn = colObject.name;



                    for (var i = 0; i < join.conditions.length; i++) {

                        if (join.conditions[i].id === newCondition.id) {

                            join.conditions[i].rightTableAlias = newCondition.rightTableAlias;

                            join.conditions[i].rightColumn = newCondition.rightColumn;

                            break;

                        }

                    }

                    thisView.oController.oData.updateQueryJoin(join);

                    thisView.oMainView.generateSQL();

                });

            }, this));



            var deleteData = [conditionRowId, newCondition, join];

            var oDeleteConditionButton = new sas.hc.m.Button({

                id: this.createId("deleteConditionButton"),

                icon: sas.icons.HC.DELETE,

                tooltip: "{i18n>queryDeleteCondition.txt}",

                press: [deleteData, this.onDeleteConditionPressed, this]

            });

            oDeleteConditionButton.setVisible(false);



            var addConditionParms = [conditionRowId, 0, join];

            var oAddConditionButton = new sas.hc.m.Button({

                id: this.createId("addConditionButton"),

                icon: sas.icons.HC.ADDROW,

                tooltip: "{i18n>queryAddCondition.txt}",

                press: [addConditionParms, this.onAddConditionPressed, this]

            });

            oAddConditionButton.setVisible(false);



            oLeftConditionCell = new sap.ui.commons.layout.MatrixLayoutCell().addStyleClass("queryJoinCondition");;

            oOperatorCell = new sap.ui.commons.layout.MatrixLayoutCell();

            oRightConditionCell = new sap.ui.commons.layout.MatrixLayoutCell();

            oDeleteConditionCell = new sap.ui.commons.layout.MatrixLayoutCell();

            oAddConditionCell = new sap.ui.commons.layout.MatrixLayoutCell();



            oLeftConditionCell.addContent(oLeftConditionCompositeInput);

            oOperatorCell.addContent(oOperatorButton);

            oOperatorCell.addContent(oOperatorEqualToButton);

            oOperatorCell.addContent(oOperatorIsNotEqualToButton);

            oOperatorCell.addContent(oOperatorIsLessThanButton);

            oOperatorCell.addContent(oOperatorIsLessThanOrEqualToButton);

            oOperatorCell.addContent(oOperatorIsGreaterThanButton);

            oOperatorCell.addContent(oOperatorIsGreaterThanOrEqualToButton);

            oRightConditionCell.addContent(oRightConditionCompositeInput);

            oDeleteConditionCell.addContent(oDeleteConditionButton);

            oAddConditionCell.addContent(oAddConditionButton);



            this.addRowControlHighlightDelegates(oLeftConditionCompositeInput);

            this.addRowControlHighlightDelegates(oOperatorButton);

            this.addRowControlHighlightDelegates(oRightConditionCompositeInput);

            this.addRowControlHighlightDelegates(oDeleteConditionButton);

            this.addRowControlHighlightDelegates(oAddConditionButton);



            var oConditionRow = new sap.ui.commons.layout.MatrixLayoutRow({

                id: conditionRowId,

                height: '45px'

            });



            oConditionRow.addCell(oLeftConditionCell);

            oConditionRow.addCell(oOperatorCell);

            oConditionRow.addCell(oRightConditionCell);

            oConditionRow.addCell(oDeleteConditionCell);

            oConditionRow.addCell(oAddConditionCell);



            var joinAndCondition = [join, newCondition];

            var conditionRowData = ["Condition Row", joinAndCondition];

            oConditionRow.data("rowData", conditionRowData);



            this.rowsJoinMatrixLayout.addRow(oConditionRow);



            // ############################ create an empty buffer row between joins

            var emptyRowId = this.createId("emptyRowId");



            var oEmptyRow = new sap.ui.commons.layout.MatrixLayoutRow({

                id: emptyRowId,

                height: '35px'

            });



            var emptyText = new sas.hc.m.Text({

                id: this.createId("emptyText"),

                text: ""

            });

            emptyText.setVisible(false);

            this.addRowControlHighlightDelegates(emptyText);

            oEmptyCell = new sap.ui.commons.layout.MatrixLayoutCell();

            oEmptyCell.addContent(emptyText);

            oEmptyRow.addCell(oEmptyCell);





            var emptyRowData = ["Empty Row", join];

            oEmptyRow.data("rowData", emptyRowData);

            this.rowsJoinMatrixLayout.addRow(oEmptyRow);

        },



        updateQueryTables: function(newData, changeType){                       



            for (var i = 0; i < this.oJoinSelectLists.length; i++) {



                var originalKey;

                var originalTable;

                if (i > 0) {

                    originalTable = this.oJoinSelectLists[i][0].rightTable;

                }

                else {

                    originalTable = this.oJoinSelectLists[i][0].leftTable;

                }

                var originalKey = "(" + originalTable.alias + ") " + originalTable.libname + "." + originalTable.member;

                this.oJoinSelectLists[i][1].removeAllItems();                   

                for (var j = 0; j < this.oController.oData.getQueryTables().length; j++)

                {

                    var table = this.oController.oData.getQueryTables()[j];

                    var itemText = "(" + table.alias + ") " + table.libname + "." + table.member

                    var tableItem = new sas.hc.ui.core.Item({

                        key: itemText,

                        tooltip: itemText,

                        text: itemText

                    });

                    this.oJoinSelectLists[i][1].addItem(tableItem);

                }

                this.oJoinSelectLists[i][1].setSelectedKey(originalKey);

            }

        },



        addListItems: function (oControl, itemsArray) {

            for (var i = 0; i < itemsArray.length; i++) {

                oControl.addItem(itemsArray[i]);

            }

        },



        createConditionRowForJoin: function (positionIndex, conditionIndex, join) {



            var conditionRowId = this.createId("conditionRowId");



            var oLeftConditionCompositeInput = new sas.hc.m.CompositeInput({

                id: this.createId("leftConditionCompositeInput"),

                inputProperties: {

                    type: sap.m.InputType.Text,

                    editable: false,

                    tooltip: "",

                    value: ""

                },

                buttonProperties: {

                    icon: sas.icons.HC.COLUMN,

                    tooltip: ""

                }

            });

            var leftInputField = oLeftConditionCompositeInput.getAggregation("input");



            var leftTableAlias = "";

            var leftColumn = "";

            var leftInputValue = "";

            if (join.leftTable !== null) {

                leftInputValue = join.leftTable.alias + "." + join.leftTable.data.columns[0].name;

                leftTableAlias = join.leftTable.alias;

                leftColumn = join.leftTable.data.columns[0].name;

            }

            else {

                // go look for the default in the first join left table

                leftInputValue = this.oController.oData.getQueryJoins()[0].leftTable.alias + "." + this.oController.oData.getQueryJoins()[0].leftTable.data.columns[0].name;

                leftTableAlias = this.oController.oData.getQueryJoins()[0].leftTable.alias;

                leftColumn = this.oController.oData.getQueryJoins()[0].leftTable.data.columns[0].name;

            }

            var rightTableAlias = join.rightTable.alias;

            var rightColumn = join.rightTable.data.columns[0].name;



            var conditionId = this.createGUID();

            var newCondition =

                {

                    id: conditionId,

                    leftTableAlias: leftTableAlias,

                    leftColumn: leftColumn,

                    operator: "=",

                    rightTableAlias: rightTableAlias,

                    rightColumn: rightColumn

                };



            join.conditions.splice(conditionIndex + 1, 0, newCondition);



            this.oController.oData.updateQueryJoin(join);



            var thisView = this;



            leftInputField.setValue(leftInputValue);

            oLeftConditionCompositeInput.attachPress($.proxy(function (oEvent) {



                var tables;

                if (join.leftTable !== null) {

                    tables = [this.oController.oData.getQueryTables()[0]];

                }

                else {

                    tables = this.oController.oData.getQueryTables();

                }

                

                var useLabels = QueryViewUtils.getUseLabels();



                SelectColumnDialog.show(tables, useLabels, function (table, colObject) {



                    console.log("ok clicked table = " + table.alias + " column = " + colObject.name);

                    leftInputField.setValue(table.alias + "." + colObject.name);



                    newCondition.leftTableAlias = table.alias;

                    newCondition.leftColumn = colObject.name;



                    for (var i = 0; i < join.conditions.length; i++) {

                        if (join.conditions[i].id === newCondition.id) {

                            join.conditions[i].leftTableAlias = newCondition.leftTableAlias;

                            join.conditions[i].leftColumn = newCondition.leftColumn;

                            break;

                        }

                    }

                    thisView.oController.oData.updateQueryJoin(join);

                    thisView.oMainView.generateSQL();



                });

            }, this));



            var operatorData = [conditionRowId, join, newCondition];

            var oOperatorButton = ViewServices.createToolbarIconMenuButton50(this.createId("operatorButton"), {

                icon: sas.icons.HC.OPERATOREQUAL,

                menu: this.createOperatorMenu(operatorData),

                tooltip: "{i18n>queryIsEqualTo.txt}",

            }).addStyleClass("queryJoinOperatorButton");

            oOperatorButton.setVisible(true);



            // NOTE: All of these operator type buttons are in here to receive a translated string.  It seems that they

            // can't be changed dynamically in the event handler itself...if you try to directly reference something like

            // {i18n>queryInnerJoin.txt} in the event handler when it wasn't rendered to begin with all you seem to get is

            // "{i18n>queryInnerJoin.txt}".  Keeping these extra invisible buttons gets the string translated and into existence

            // correctly where it can then be swapped appropriately in the event handler

            // http://sww.sas.com/defects/java/iDefects/WebClient.html?defectid=S1441292

            // This can be changed if there is a different control or better way of doing this that I wasn't aware of...miburk

            var oOperatorEqualToButton = ViewServices.createToolbarIconMenuButton50(this.createId("operatorButton"), {

                tooltip: "{i18n>queryIsEqualTo.txt}",

            }).addStyleClass("queryJoinOperatorButton");

            oOperatorEqualToButton.setVisible(false);

            var oOperatorIsNotEqualToButton = ViewServices.createToolbarIconMenuButton50(this.createId("operatorButton"), {

                tooltip: "{i18n>queryIsNotEqualTo.txt}",

            }).addStyleClass("queryJoinOperatorButton");

            oOperatorIsNotEqualToButton.setVisible(false);

            var oOperatorIsLessThanButton = ViewServices.createToolbarIconMenuButton50(this.createId("operatorButton"), {

                tooltip: "{i18n>queryIsLessThan.txt}",

            }).addStyleClass("queryJoinOperatorButton");

            oOperatorIsLessThanButton.setVisible(false);

            var oOperatorIsLessThanOrEqualToButton = ViewServices.createToolbarIconMenuButton50(this.createId("operatorButton"), {

                tooltip: "{i18n>queryIsLessThanOrEqualTo.txt}",

            }).addStyleClass("queryJoinOperatorButton");

            oOperatorIsLessThanOrEqualToButton.setVisible(false);

            var oOperatorIsGreaterThanButton = ViewServices.createToolbarIconMenuButton50(this.createId("operatorButton"), {

                tooltip: "{i18n>queryIsGreaterThan.txt}",

            }).addStyleClass("queryJoinOperatorButton");

            oOperatorIsGreaterThanButton.setVisible(false);

            var oOperatorIsGreaterThanOrEqualToButton = ViewServices.createToolbarIconMenuButton50(this.createId("operatorButton"), {

                tooltip: "{i18n>queryIsGreaterThanOrEqualTo.txt}",

            }).addStyleClass("queryJoinOperatorButton");

            oOperatorIsGreaterThanOrEqualToButton.setVisible(false);



            var oRightConditionCompositeInput = new sas.hc.m.CompositeInput({

                id: this.createId("leftConditionCompositeInput"),

                inputProperties: {

                    type: sap.m.InputType.Text,

                    editable: false,

                    tooltip: "",

                    value: ""

                },

                buttonProperties: {

                    icon: sas.icons.HC.COLUMN,

                    tooltip: ""

                }

            });

            var rightInputField = oRightConditionCompositeInput.getAggregation("input");

            var rightInputValue = join.rightTable.alias + "." + join.rightTable.data.columns[0].name;



            rightInputField.setValue(rightInputValue);

            oRightConditionCompositeInput.attachPress($.proxy(function (oEvent) {

                join.rightTable.data.type = "DATA";

                var tables = join.rightTable ? [join.rightTable] : this.oController.oData.getQueryTables();

                var useLabels = QueryViewUtils.getUseLabels();

                SelectColumnDialog.show(tables, useLabels, function (table, colObject) {

                    console.log("ok clicked table = " + table.alias + " column = " + colObject.name);

                    rightInputField.setValue(table.alias + "." + colObject.name);

                    newCondition.rightTableAlias = table.alias;

                    newCondition.rightColumn = colObject.name;



                    for (var i = 0; i < join.conditions.length; i++) {

                        if (join.conditions[i].id === newCondition.id) {

                            join.conditions[i].rightTableAlias = newCondition.rightTableAlias;

                            join.conditions[i].rightColumn = newCondition.rightColumn;

                            break;

                        }

                    }

                    thisView.oController.oData.updateQueryJoin(join);

                    thisView.oMainView.generateSQL();

                });

            }, this));



            var deleteData = [conditionRowId, newCondition, join];

            var oDeleteConditionButton = new sas.hc.m.Button({

                id: this.createId("deleteConditionButton"),

                icon: sas.icons.HC.DELETE,

                tooltip: "{i18n>queryDeleteCondition.txt}",

                press: [deleteData, this.onDeleteConditionPressed, this]

            });

            oDeleteConditionButton.setVisible(false);



            var currentPos = (conditionIndex + 1);

            var addConditionParms = [conditionRowId, currentPos, join];

            var oAddConditionButton = new sas.hc.m.Button({

                id: this.createId("addConditionButton"),

                icon: sas.icons.HC.ADDROW,

                tooltip: "{i18n>queryAddCondition.txt}",

                press: [addConditionParms, this.onAddConditionPressed, this]

            });

            oAddConditionButton.setVisible(false);



            oLeftConditionCell = new sap.ui.commons.layout.MatrixLayoutCell().addStyleClass("queryJoinCondition");;

            oOperatorCell = new sap.ui.commons.layout.MatrixLayoutCell();

            oRightConditionCell = new sap.ui.commons.layout.MatrixLayoutCell();

            oDeleteConditionCell = new sap.ui.commons.layout.MatrixLayoutCell();

            oAddConditionCell = new sap.ui.commons.layout.MatrixLayoutCell();



            oLeftConditionCell.addContent(oLeftConditionCompositeInput);

            oOperatorCell.addContent(oOperatorButton);

            oOperatorCell.addContent(oOperatorEqualToButton);

            oOperatorCell.addContent(oOperatorIsNotEqualToButton);

            oOperatorCell.addContent(oOperatorIsLessThanButton);

            oOperatorCell.addContent(oOperatorIsLessThanOrEqualToButton);

            oOperatorCell.addContent(oOperatorIsGreaterThanButton);

            oOperatorCell.addContent(oOperatorIsGreaterThanOrEqualToButton);

            oRightConditionCell.addContent(oRightConditionCompositeInput);

            oDeleteConditionCell.addContent(oDeleteConditionButton);

            oAddConditionCell.addContent(oAddConditionButton);



            this.addRowControlHighlightDelegates(oLeftConditionCompositeInput);

            this.addRowControlHighlightDelegates(oOperatorButton);

            this.addRowControlHighlightDelegates(oRightConditionCompositeInput);

            this.addRowControlHighlightDelegates(oDeleteConditionButton);

            this.addRowControlHighlightDelegates(oAddConditionButton);



            var oConditionRow = new sap.ui.commons.layout.MatrixLayoutRow({

                id: conditionRowId,

                height: '45px'

            });



            oConditionRow.addCell(oLeftConditionCell);

            oConditionRow.addCell(oOperatorCell);

            oConditionRow.addCell(oRightConditionCell);

            oConditionRow.addCell(oDeleteConditionCell);

            oConditionRow.addCell(oAddConditionCell);



            var joinAndCondition = [join, newCondition];

            var conditionRowData = ["Condition Row", joinAndCondition];

            oConditionRow.data("rowData", conditionRowData);

            this.rowsJoinMatrixLayout.insertRow(oConditionRow, positionIndex);



            this.oMainView.generateSQL();

        },



        deleteJoinGroup: function (join) {

            var rows = this.oJoinMatrixLayout.getRows();

            for (var i = 0; i < rows.length; i++) {



                var data = rows[i].data("rowData");

                if (data) {

                    //this.oJoinMatrixLayout.removeRow(i);

                }

            }

        },



        loadViewFromState: function () {

            if (this.oController.oData.getQueryTables() !== undefined) {



                if (this.oController.oData.getQueryTables().length > 0) {



                    this.primaryTable = this.oController.oData.getQueryTables()[0];

                    var text = this.oController.oData.getQueryTables()[0].libname + "." + this.oController.oData.getQueryTables()[0].member;



                    var item = new sap.ui.core.ListItem({

                        key: text,

                        tooltip: text,

                        text: text,

                        icon: sas.icons.HC.SASDATASET

                    });



                    // TODO: Need to fix; commenting out for now

                    //this.oPrimaryTableSelect.addItem(item);

                }

                if (this.oController.oData.getQueryTables().length > 1) {



                    this.secondaryTable = this.oController.oData.getQueryTables()[1];

                    this.oSecondaryTableSelect.setDisplayListItemIcon(true);

                    this.oSecondaryTableSelect.removeAllItems();



                    var text = this.oController.oData.getQueryTables()[1].libname + "." + this.oController.oData.getQueryTables()[1].member;



                    var item = new sap.ui.core.ListItem({

                        key: text,

                        tooltip: text,

                        text: text,

                        icon: sas.icons.HC.SASDATASET

                    });



                    this.oSecondaryTableSelect.addItem(item);

                    this.oSecondaryTableSelect.setSelectedItem(item);

                    this.createConditionRowForJoin(1, this.oController.oData.getQueryTables()[1]);

                    this.oPrimaryVariableSelect.setSelectedKey(this.oController.oData.getPrimaryTableKey());

                    this.oSecondaryVariableSelect.setSelectedKey(this.oController.oData.getSecondaryTableKey());



                    var joinType = this.oController.oData.getJoinType();



                    if (joinType === "INNER JOIN") {

                        this.oJoinTypeButton.setIcon(sas.icons.HC.VENNDIAGRAMAND);

                        this.oJoinTypeButton.setTooltip("Inner Join");

                    } else if (joinType === "LEFT JOIN") {

                        this.oJoinTypeButton.setIcon(sas.icons.HC.VENNDIAGRAMLEFTJOIN);

                        this.oJoinTypeButton.setTooltip("Left Join");

                    } else if (joinType === "RIGHT JOIN") {

                        this.oJoinTypeButton.setIcon(sas.icons.HC.VENNDIAGRAMRIGHTJOIN);

                        this.oJoinTypeButton.setTooltip("Right Join");

                    } else if (joinType === "FULL JOIN") {

                        this.oJoinTypeButton.setIcon(sas.icons.HC.VENNDIAGRAMCROSSJOIN);

                        this.oJoinTypeButton.setTooltip("Full Join");

                    }



                    var operatorIcon;

                    switch (this.oController.oData.getConditionOperator()) {

                        case "=":

                            operatorIcon = sas.icons.HC.OPERATOREQUAL;

                            break;

                        case "<>":

                            operatorIcon = sas.icons.HC.OPERATORNOTEQUAL;

                            break;

                        case "<":

                            operatorIcon = sas.icons.HC.OPERATORLESSTHAN;

                            break;

                        case ">":

                            operatorIcon = sas.icons.HC.OPERATORGREATERTHAN;

                            break;

                        case "<=":

                            operatorIcon = sas.icons.HC.OPERATORLESSTHANOREQUAL;

                            break;

                        case ">=":

                            operatorIcon = sas.icons.HC.OPERATORGREATORTHANOREQUAL;

                            break;

                    }

                    this.oOperatorTypeButton.setIcon(operatorIcon);



                    this.swapJoinLayoutMatrix(true);

                }

            }

        },



        removeTableFromJoins: function (newData) {



            this.oController.oData.removeQueryJoin(newData.libname, newData.member, newData.alias);



            var rowsToDelete = [];



            var rows = this.oJoinMatrixLayout.getRows();

            for (var i = 0; i < rows.length; i++) {



                var data = rows[i].data("rowData");

                if (data) {



                    var rowType = data[0];

                    var rowJoin = null;

                    if (rowType === "Title Row") {

                        rowJoin = data[1];

                    }

                    if (rowType === "Table Row 1") {

                        rowJoin = data[1];

                    }

                    if (rowType === "Table Row 2") {

                        rowJoin = data[1];

                    }

                    if (rowType === "Condition Row") {

                        var rowJoinAndCondition = data[1];

                        rowJoin = rowJoinAndCondition[0];

                    }

                    if (rowType === "Empty Row") {

                        rowJoin = data[1];

                    }

                    if (rowJoin.joinType !== "SINGLE TABLE") {

                        if (rowJoin.rightTable.alias === newData.alias &&

                            rowJoin.rightTable.libname === newData.libname &&

                            rowJoin.rightTable.member === newData.member) {

                            rowsToDelete.push(i);

                        }

                    }

                    else {

                        rowsToDelete.push(i);

                    }

                }

            }



            for (var i = rowsToDelete.length - 1; i >= 0; i--) {

                this.oJoinMatrixLayout.removeRow(rowsToDelete[i]);

            }



            // update the join titles

            for (var i = 2; i < rows.length; i++) {



                var rowData = rows[i].data("rowData");

                var rowType = rowData[0];

                var join = rowData[1];



                if (rowType == "Title Row") {



                    var cells = rows[i].getCells();

                    var rowTitleText = cells[0].getContent()[0];

                    var titleString = rowTitleText.getText();



                    var joinList = this.oController.oData.getQueryJoins();

                    var joinNumber = 0;

                    for (j = 0; j < joinList.length; j++) {

                        if (join.id === joinList[j].id) {

                            joinNumber = j + 1;



                            titleString = "Join " + (joinNumber);

                            rowTitleText.setText(titleString);

                        }

                    }

                }



                if (rowType == "Table Row 2") {



                    var cells = rows[i].getCells();

                    var rowTitleText = cells[0].getContent()[0];

                    var titleString = rowTitleText.getText();



                    var joinList = this.oController.oData.getQueryJoins();

                    var joinNumber = 0;

                    for (j = 0; j < joinList.length; j++) {

                        if (join.id === joinList[j].id) {

                            joinNumber = j + 1;



                            titleString = "Results from Join " + (joinNumber - 1);

                            rowTitleText.setText(titleString);

                        }

                    }

                }

            }

        },



        addTableToJoins: function (newData) {



            // keep track of the newly added data on the query object

            this.oController.oData.addQueryTable(newData);



            if (this.oController.oData.getQueryTables().length > 1) {

                // we have at least two tables, so we can show the joins...

                this.swapJoinLayoutMatrix(true);

            }

            else {

                // there is only one table, so show the zero state for the joins...

                this.swapJoinLayoutMatrix(false);

            }



            // look to see if the query has any joins

            if (this.oController.oData.getQueryJoins().length > 0) {

                // there is at least one join.  we need to add the new table to the appropriate select controls



                if (this.oController.oData.getQueryTables().length === 2) {



                    // get a copy of the first join

                    var firstJoin = this.oController.oData.getQueryJoins()[0];



                    // set the join type to a default of INNER JOIN and assign the right table

                    firstJoin.joinType = "INNER JOIN";

                    firstJoin.rightTable = newData;

                    this.oController.oData.updateQueryJoin(firstJoin);

                    this.createJoinGroup(firstJoin, true);

                }

                else if (this.oController.oData.getQueryJoins()[0].joinType !== "SINGLE TABLE") {



                    // there is already one join, so now we are going to create an inner join to the results of the previous one



                    // there are two or more joins...add a new join

                    var joinId = this.createGUID();

                    var joinConditions = [];

                    var newJoin = { id: joinId, leftTable: null, joinType: "INNER JOIN", rightTable: newData, conditions: joinConditions };

                    this.oController.oData.addQueryJoin(newJoin);

                    this.createJoinGroup(newJoin);

                }

            }

            else {

                var id = this.createGUID();

                var joinConditions = [];

                var join = { id: id, leftTable: newData, joinType: "SINGLE TABLE", rightTable: null, conditions: joinConditions };

                this.oController.oData.addQueryJoin(join);

            }

        },



        createGUID: function () {

            return this.s4() + this.s4() + '-' + this.s4() + '-' + this.s4() + '-' + this.s4() + '-' + this.s4() + this.s4() + this.s4();

        },



        s4: function () {

            return Math.floor((1 + Math.random()) * 0x10000)

                .toString(16)

                .substring(1);

        },



        updateJoins: function (newData, changeType, oView) {



            if (changeType === "tableAdded") {

                this.addTableToJoins(newData);

            } else if (changeType === "tableDeleted") {

                this.removeTableFromJoins(newData);

            }

            if (this.oController.oData.getQueryTables().length > 1) {

                this.updateQueryTables(newData, changeType);

            }

            this.oMainView.generateSQL();

        },



        resetPane: function () {

            alert("Reset join pane.");

        },



        onDeleteConditionPressed: function (oEvent, deleteData) {



            var rowId = deleteData[0];

            var condition = deleteData[1];

            var join = deleteData[2];



            var content = this.oMainLayout.getContent(BorderLayoutAreaTypes.center)[0];



            if (!content || content !== this.rowsJoinMatrixLayout) {

                return;

            }



            var rows = this.oJoinMatrixLayout.getRows();

            for (var i = 0; i < rows.length; i++) {

                if (rows[i].sId === rowId) {

                    this.oJoinMatrixLayout.removeRow(i);

                    break;

                }

            }



            for (var i = 0; i < join.conditions.length; i++) {

                if (join.conditions[i].id === condition.id) {

                    join.conditions.splice(i, 1);

                    break;

                }

            }

            this.oController.oData.updateQueryJoin(join);

            this.oMainView.generateSQL();

        },



        onAddConditionPressed: function (oEvent, parms) {



            var rowId = parms[0];

            var currentConditionIndex = parms[1];

            var join = parms[2];



            var content = this.oMainLayout.getContent(BorderLayoutAreaTypes.center)[0];



            if (!content || content !== this.rowsJoinMatrixLayout) {

                return;

            }



            var rows = this.oJoinMatrixLayout.getRows();

            for (var i = 0; i < rows.length; i++) {

                if (rows[i].sId === rowId) {

                    this.createConditionRowForJoin(i + 1, currentConditionIndex, join);

                    break;

                }

            }

        },



        createJoinTypeMenu: function (parms) {



            var uniqueRowId = parms[0];

            var joinToModify = parms[1];



            var oInnerJoinItem = ViewServices.createMenuItem(this.createId("innerJoinMenuItem"), {

                text: "{i18n>queryInnerJoin.txt}",

                icon: sas.icons.HC.VENNDIAGRAMAND

            });



            var oInnerJoinParam = { rowId: uniqueRowId, joinType: "Inner Join", join: joinToModify };

            oInnerJoinItem.attachPress(oInnerJoinParam, this.onChangeJoinType, this);



            var oLeftJoinItem = ViewServices.createMenuItem(this.createId("leftJoinMenuItem"), {

                text: "{i18n>queryLeftJoin.txt}",

                icon: sas.icons.HC.VENNDIAGRAMLEFTJOIN

            });

            var oLeftJoinParam = { rowId: uniqueRowId, joinType: "Left Join", join: joinToModify };

            oLeftJoinItem.attachPress(oLeftJoinParam, this.onChangeJoinType, this);



            var oRightJoinItem = ViewServices.createMenuItem(this.createId("rightJoinMenuItem"), {

                text: "{i18n>queryRightJoin.txt}",

                icon: sas.icons.HC.VENNDIAGRAMRIGHTJOIN

            });

            var oRightJoinParam = { rowId: uniqueRowId, joinType: "Right Join", join: joinToModify };

            oRightJoinItem.attachPress(oRightJoinParam, this.onChangeJoinType, this);



            var oOuterJoinItem = ViewServices.createMenuItem(this.createId("rightJoinMenuItem"), {

                text: "{i18n>queryOuterJoin.txt}",

                icon: sas.icons.HC.VENNDIAGRAMCROSSJOIN

            });

            var oOuterJoinParam = { rowId: uniqueRowId, joinType: "Full Join", join: joinToModify };

            oOuterJoinItem.attachPress(oOuterJoinParam, this.onChangeJoinType, this);



            var oChangeJoinTypeMenu = ViewServices.createMenu(this.createId("changeJoinTypeMenu"));

            oChangeJoinTypeMenu.addItem(oInnerJoinItem);

            oChangeJoinTypeMenu.addItem(oLeftJoinItem);

            oChangeJoinTypeMenu.addItem(oRightJoinItem);

            oChangeJoinTypeMenu.addItem(oOuterJoinItem);



            return oChangeJoinTypeMenu;

        },



        onChangeJoinType: function (oEvent, oJoinParam) {



            var content = this.oMainLayout.getContent(BorderLayoutAreaTypes.center)[0];



            if (!content || content !== this.rowsJoinMatrixLayout) {

                return;

            }



            var rows = this.oJoinMatrixLayout.getRows();

            for (var i = 0; i < rows.length; i++) {

                if (rows[i].sId === oJoinParam.rowId) {



                    var cells = rows[i].getCells();

                    var joinButton = cells[1].getContent();

                    var joinToModify = oJoinParam.join;



                    if (oJoinParam.joinType === "Inner Join") {

                        joinButton[0].setIcon(sas.icons.HC.VENNDIAGRAMAND);

                        joinButton[0].setTooltip(joinButton[1].getTooltip());

                    } else if (oJoinParam.joinType === "Left Join") {

                        joinButton[0].setIcon(sas.icons.HC.VENNDIAGRAMLEFTJOIN);

                        joinButton[0].setTooltip(joinButton[2].getTooltip());

                    } else if (oJoinParam.joinType === "Right Join") {

                        joinButton[0].setIcon(sas.icons.HC.VENNDIAGRAMRIGHTJOIN);

                        joinButton[0].setTooltip(joinButton[3].getTooltip());

                    } else if (oJoinParam.joinType === "Full Join") {

                        joinButton[0].setIcon(sas.icons.HC.VENNDIAGRAMCROSSJOIN);

                        joinButton[0].setTooltip(joinButton[4].getTooltip());

                    }



                    joinToModify.joinType = oJoinParam.joinType.toUpperCase();

                    this.oController.oData.updateQueryJoin(joinToModify);

                    this.oMainView.generateSQL();

                    break;

                }

            }

        },



        createOperatorMenu: function (operatorData) {



            var oEqualItem = ViewServices.createMenuItem(this.createId("equalMenuItem"), {

                text: "{i18n>queryIsEqualTo.txt}",

                icon: sas.icons.HC.OPERATOREQUAL

            });

            var equalParam = { operatorData: operatorData, operator: "=" };

            oEqualItem.attachPress(equalParam, this.onChangeOperator, this);



            var oNotEqualItem = ViewServices.createMenuItem(this.createId("notEqualMenuItem"), {

                text: "{i18n>queryIsNotEqualTo.txt}",

                icon: sas.icons.HC.OPERATORNOTEQUAL

            });

            var notEqualParam = { operatorData: operatorData, operator: "<>" };

            oNotEqualItem.attachPress(notEqualParam, this.onChangeOperator, this);



            var oLessThanItem = ViewServices.createMenuItem(this.createId("lessThanMenuItem"), {

                text: "{i18n>queryIsLessThan.txt}",

                icon: sas.icons.HC.OPERATORLESSTHAN

            });

            var lessThanParam = { operatorData: operatorData, operator: "<" };

            oLessThanItem.attachPress(lessThanParam, this.onChangeOperator, this);



            var oLessThanEqualItem = ViewServices.createMenuItem(this.createId("lessThanOrEqualMenuItem"), {

                text: "{i18n>queryIsLessThanOrEqualTo.txt}",

                icon: sas.icons.HC.OPERATORLESSTHANOREQUAL

            });

            var lessThanEqualParam = { operatorData: operatorData, operator: "<=" };

            oLessThanEqualItem.attachPress(lessThanEqualParam, this.onChangeOperator, this);



            var oGreaterThanItem = ViewServices.createMenuItem(this.createId("greaterThanMenuItem"), {

                text: "{i18n>queryIsGreaterThan.txt}",

                icon: sas.icons.HC.OPERATORGREATERTHAN

            });

            var greaterThanParam = { operatorData: operatorData, operator: ">" };

            oGreaterThanItem.attachPress(greaterThanParam, this.onChangeOperator, this);



            var oGreaterThanEqualItem = ViewServices.createMenuItem(this.createId("greaterThanOrEqualMenuItem"), {

                text: "{i18n>queryIsGreaterThanOrEqualTo.txt}",

                icon: sas.icons.HC.OPERATORGREATERTHANOREQUAL

            });

            var greaterThanEqualParam = { operatorData: operatorData, operator: ">=" };

            oGreaterThanEqualItem.attachPress(greaterThanEqualParam, this.onChangeOperator, this);



            var oChangeOperatorMenu = ViewServices.createMenu(this.createId("changeOperatorMenu"));

            oChangeOperatorMenu.addItem(oEqualItem);

            oChangeOperatorMenu.addItem(oNotEqualItem);

            oChangeOperatorMenu.addItem(oGreaterThanItem);

            oChangeOperatorMenu.addItem(oLessThanItem);

            oChangeOperatorMenu.addItem(oGreaterThanEqualItem);

            oChangeOperatorMenu.addItem(oLessThanEqualItem);



            return oChangeOperatorMenu;

        },



        onChangeOperator: function (oEvent, oOperatorParam) {



            var content = this.oMainLayout.getContent(BorderLayoutAreaTypes.center)[0];



            var operatorData = oOperatorParam.operatorData;

            var uniqueRowId = operatorData[0];

            var join = operatorData[1];

            var conditionToUpdate = operatorData[2];

            conditionToUpdate.operator = oOperatorParam.operator;



            for (var i = 0; i < join.conditions.length; i++) {

                if (join.conditions[i].id === conditionToUpdate.id) {

                    join.conditions[i].operator = conditionToUpdate.operator;

                    break;

                }

            }

            this.oController.oData.updateQueryJoin(join);



            if (!content || content !== this.rowsJoinMatrixLayout) {

                return;

            }



            var rows = this.oJoinMatrixLayout.getRows();

            for (var i = 0; i < rows.length; i++) {

                if (rows[i].sId === uniqueRowId) {



                    var cells = rows[i].getCells();

                    var operatorButton = cells[1].getContent();

                    var operatorIcon;

                    switch (oOperatorParam.operator) {

                        case "=":

                            operatorIcon = sas.icons.HC.OPERATOREQUAL;

                            break;

                        case "<>":

                            operatorIcon = sas.icons.HC.OPERATORNOTEQUAL;

                            break;

                        case "<":

                            operatorIcon = sas.icons.HC.OPERATORLESSTHAN;

                            break;

                        case ">":

                            operatorIcon = sas.icons.HC.OPERATORGREATERTHAN;

                            break;

                        case "<=":

                            operatorIcon = sas.icons.HC.OPERATORLESSTHANOREQUAL;

                            break;

                        case ">=":

                            operatorIcon = sas.icons.HC.OPERATORGREATERTHANOREQUAL;

                            break;

                    }

                    operatorButton[0].setIcon(operatorIcon);



                    if (oOperatorParam.operator === "=") {

                        operatorButton[0].setTooltip(operatorButton[1].getTooltip());

                    } else if (oOperatorParam.operator === "<>") {

                        operatorButton[0].setTooltip(operatorButton[2].getTooltip());

                    } else if (oOperatorParam.operator === "<") {

                        operatorButton[0].setTooltip(operatorButton[3].getTooltip());

                    } else if (oOperatorParam.operator === "<=") {

                        operatorButton[0].setTooltip(operatorButton[4].getTooltip());

                    } else if (oOperatorParam.operator === ">") {

                        operatorButton[0].setTooltip(operatorButton[5].getTooltip());

                    } else if (oOperatorParam.operator === ">=") {

                        operatorButton[0].setTooltip(operatorButton[6].getTooltip());

                    }



                    this.oMainView.generateSQL();

                    break;

                }

            }

        }

    });

});
