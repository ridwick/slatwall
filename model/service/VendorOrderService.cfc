/*

    Slatwall - An Open Source eCommerce Platform
    Copyright (C) ten24, LLC
	
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
	
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
	
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this program statically or dynamically with other modules is
    making a combined work based on this program.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
	
    As a special exception, the copyright holders of this program give you
    permission to combine this program with independent modules and your 
    custom code, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting program under terms 
    of your choice, provided that you follow these specific guidelines: 

	- You also meet the terms and conditions of the license of each 
	  independent module 
	- You must not alter the default display of the Slatwall name or logo from  
	  any part of the application 
	- Your custom code must not alter or create any files inside Slatwall, 
	  except in the following directories:
		/integrationServices/

	You may copy and distribute the modified version of this program that meets 
	the above guidelines as a combined work under the terms of GPL for this program, 
	provided that you include the source code of that other code when and as the 
	GNU GPL requires distribution of source code.
    
    If you modify this program, you may extend this exception to your version 
    of the program, but you are not obligated to do so.

Notes:

*/
component extends="HibachiService" persistent="false" accessors="true" output="false" {
	
	property name="venderOrderDAO" type="any";
	
	property name="addressService" type="any";
	property name="locationService" type="any";
	property name="productService" type="any";
	property name="settingService" type="any";
	property name="skuService" type="any";
	property name="stockService" type="any";
	property name="taxService" type="any";
	property name="typeService" type="any";
	property name="vendorService" type="any";
	
	// ===================== START: Logical Methods ===========================
	
	// =====================  END: Logical Methods ============================
	
	// ===================== START: DAO Passthrough ===========================
	
	public any function getVendorOrderSmartList(struct data={}) {
		arguments.entityName = "SlatwallVendorOrder";
		
		var smartList = getHibachiDAO().getSmartList(argumentCollection=arguments);
		
		smartList.joinRelatedProperty("SlatwallVendorOrder","vendor");
			
		smartList.addKeywordProperty(propertyIdentifier="vendorOrderNumber", weight=9);
		smartList.addKeywordProperty(propertyIdentifier="vendor.vendorName", weight=4);	
		
		return smartList;
	}
	
	public any function getStockReceiverSmartList(string vendorOrderID) {
		var smartList = getStockService().getStockReceiverSmartlist();	
		smartList.addFilter("stockReceiverItems.vendorOrderItem.vendorOrder.vendorOrderID", arguments.vendorOrderID);
		return smartList;
	}
	
	public any function getStockReceiverItemSmartList(any stockReceiver) {
		var smartList = getStockService().getStockReceiverItemSmartlist();	
		smartList.addFilter("stockReceiver.stockReceiverID", arguments.stockReceiver.getStockReceiverID());
		return smartList;
	}
		
	public any function isProductInVendorOrder(required any productID, required any vendorOrderID){
		return getVenderOrderDAO().isProductInVendorOrder(arguments.productID, arguments.vendorOrderID);
	}
	
	public any function getQuantityOfStockAlreadyOnOrder(required any vendorOrderID, required any skuID, required any stockID) {
		return getVenderOrderDAO().getQuantityOfStockAlreadyOnOrder(arguments.vendorOrderId, arguments.skuID, arguments.stockID);
	}
	
	public any function getQuantityOfStockAlreadyReceived(required any vendorOrderID, required any skuID, required any stockID) {
		return getVenderOrderDAO().getQuantityOfStockAlreadyReceived(arguments.vendorOrderId, arguments.skuID, arguments.stockID);
	}
	
	public any function getSkusOrdered(required any vendorOrderID) {
		return getVenderOrderDAO().getSkusOrdered(arguments.vendorOrderId);
	}
	
	public any function getVendorSkuByVendorSkuCode(required string vendorSkuCode){
		return getDao('vendorOrderDao').getVendorSkuByVendorSkuCode(arguments.vendorSkuCode);
	}
	
	// ===================== START: DAO Passthrough ===========================
	
	// ===================== START: Process Methods ===========================
	
	public any function processVendorOrder_fulfill(required any vendorOrder, required processObject){
		var vendorOrderDelivery = this.newVendorOrderDelivery();
		vendorOrderDelivery.setVendorOrder(arguments.vendorOrder);
		vendorOrderDelivery.setLocation(arguments.processObject.getLocation());
		
		//add items to vendorOrderDelivery
		addVendorOrderItemsToVendorOrderDelivery(vendorOrderDelivery,arguments.processObject);
		
		arguments.vendorOrderDelivery = this.saveVendorOrderDelivery(vendorOrderDelivery);
		
			// Update the orderStatus
		this.processVendorOrder(arguments.vendorOrder, {updateItems=true}, 'updateStatus');
		

		return arguments.vendorOrder;
	}
	
	public any function processVendorOrder_updateStatus(required any vendorOrder, struct data) {
		param name="arguments.data.updateItems" default="false";

		// Get the original order status code
		var originalVendorOrderStatus = arguments.vendorOrder.getVendorOrderStatusType().getSystemCode();

		// First we make sure that this order status is not 'closed' because we cannot automatically update those statuses
		if(!listFindNoCase("vostClosed", arguments.vendorOrder.getVendorOrderStatusType().getSystemCode())) {

			if(
				arguments.vendorOrder.getQuantityUndelivered() == 0
			){
				arguments.vendorOrder.setVendorOrderStatusType(  getTypeService().getTypeBySystemCode("vostClosed") );
			//if some of the items are not delivered then set the status
			} else if(arguments.vendorOrder.getQuantityUndelivered() >= 1){
				arguments.vendorOrder.setVendorOrderStatusType( getTypeService().getTypeBySystemCode("vostPartiallyDelivered") );
			}

		}
		arguments.vendorOrder = this.saveVendorOrder(arguments.vendorOrder);

		return arguments.vendorOrder;
	}
	
	public any function addVendorOrderItemsToVendorOrderDelivery(required vendorOrderDelivery, required any processObject){
		for(var vendorOrderItemData in arguments.processObject.getVendorOrderItems()){
			
			var vendorOrderItem = this.getVendorOrderItem(vendorOrderItemData.vendorOrderItem.vendorOrderItemID);
			
			if(vendorOrderItem.getQuantityUndelivered()) {
				if(isNumeric(vendorOrderItemData['quantity']) && vendorOrderItemData['quantity'] > 0){
					var vendorOrderDeliveryItem = this.newVendorOrderDeliveryItem();
					vendorOrderDeliveryItem.setQuantity(vendorOrderItemData['quantity']);
					vendorOrderDeliveryItem.setVendorOrderItem(vendorOrderItem);
					vendorOrderDeliveryItem.setVendorOrderDelivery(arguments.vendorOrderDelivery);
					vendorOrderDeliveryItem.setStock(getStockService().getStockBySkuAndLocation(sku=vendorOrderDeliveryItem.getVendorOrderItem().getStock().getSku(), location=arguments.vendorOrderDelivery.getLocation()));
					this.saveVendorOrderDeliveryItem(vendorOrderDeliveryItem);
				}
			}
		}
		return vendorOrderDelivery;
	}
	
	public any function processVendorOrder_addVendorOrderItem(required any vendorOrder, required any processObject){
		
		var vendorOrderItemType = getTypeService().getTypeBySystemCode( arguments.processObject.getVendorOrderItemTypeSystemCode() );
		var newVendorOrderItem = this.newVendorOrderItem();
		newVendorOrderItem.setVendorOrderItemType( vendorOrderItemType );
		newVendorOrderItem.setVendorOrder( arguments.vendorOrder );
		newVendorOrderItem.setCurrencyCode( arguments.vendorOrder.getCurrencyCode() );
		
		if(arguments.processObject.getVendorOrderItemTypeSystemCode() == 'voitReturn'){
			var deliverFromLocation = getStockService().getStockBySkuAndLocation(arguments.processObject.getSku(),getLocationService().getLocation(arguments.processObject.getDeliverFromLocationID()));
			newVendorOrderItem.setStock( deliverFromLocation );
		}
		
		if(arguments.processObject.getVendorOrderItemTypeSystemCode() == 'voitPurchase'){
			var deliverToLocation = getStockService().getStockBySkuAndLocation(arguments.processObject.getSku(),getLocationService().getLocation(arguments.processObject.getDeliverToLocationID()));
			newVendorOrderItem.setStock( deliverToLocation );
		}
		newVendorOrderItem.setSku( arguments.processObject.getSku() );
		
		newVendorOrderItem.setCost( arguments.processObject.getCost() );
			
		//if vendor sku code was provided then find existing Vendor Sku or create one
		if(!isNull(arguments.processObject.getVendorSkuCode()) && len(arguments.processObject.getVendorSkuCode())){
			var vendorSku = getVendorSkuByVendorSkuCode(arguments.processObject.getVendorSkuCode());
			if(isNull(vendorSku)){
				vendorSku = this.newVendorSku();
				vendorSku.setVendor(arguments.vendorOrder.getVendor());
				vendorSku.setSku(arguments.processObject.getSku());
				
				//get alternateSkuCode and if it's new then set it up
				var alternateSkuCode = getService('skuService').getAlternateSkuCodeByAlternateSkuCode(arguments.processObject.getVendorSkuCode(),true);
				if(alternateSkuCode.getNewFlag()){
					alternateSkuCode.setSku(arguments.processObject.getSku());
					//type of vendor sku
					var vendorSkuType = getService('TypeService').getType('444df2cad53c6edae52df82f27efe892');
					alternateSkuCode.setAlternateSkuCodeType(vendorSkuType);
					alternateSkuCode.setAlternateSkuCode(arguments.processObject.getVendorSkuCode());
					getService('skuService').saveAlternateSkuCode(alternateSkuCode);
				}
				vendorSku.setAlternateSkuCode(alternateSkuCode);
				
			}
			//set last vendorOrderItem on the vendorSku
			vendorSku.setLastVendorOrderItem(newVendorOrderItem);
			newVendorOrderItem.setVendorAlternateSkuCode(vendorSku.getAlternateSkuCode());
			this.saveVendorSku(vendorSku);
		}
		
		newVendorOrderItem.setQuantity( arguments.processObject.getQuantity() );
		
		this.saveVendorOrderItem(newVendorOrderItem);
		
		return arguments.vendorOrder;
	}
	
	public any function processVendorOrder_receive(required any vendorOrder, required any processObject){
		

		var stockReceiver = getStockService().newStockReceiver();
		stockReceiver.setReceiverType( "vendorOrder" );
		stockReceiver.setVendorOrder( arguments.vendorOrder );
		
		if(!isNull(processObject.getPackingSlipNumber())) {
			stockReceiver.setPackingSlipNumber( processObject.getPackingSlipNumber() );
		}
		if(!isNull(processObject.getBoxCount())) {
			stockReceiver.setBoxCount( processObject.getBoxCount() );
		}

		var locationEntity = getLocationService().getLocation( arguments.processObject.getLocationID() );

		// Automatically keep preference history of vendor and product/sku for future convenience
		var newVendorProductPreferenceFlag = false;
		
		for(var thisRecord in arguments.data.vendorOrderItems) {
			
			if(val(thisRecord.quantity) gt 0) {
				
				var foundItem = false;
				var vendorOrderItem = this.getVendorOrderItem( thisRecord.vendorOrderItem.vendorOrderItemID );
				var stock = getStockService().getStockBySkuAndLocation( vendorOrderItem.getStock().getSku(), locationEntity );
				
				var stockReceiverItem = getStockService().newStockReceiverItem();

				stockreceiverItem.setQuantity( thisRecord.quantity );
				stockreceiverItem.setStock( stock );
				stockreceiveritem.setCost( vendorOrderItem.getCost() );
				stockreceiverItem.setVendorOrderItem( vendorOrderItem );
				stockreceiverItem.setCurrencyCode(vendorOrderItem.getCurrencyCode());
				stockreceiverItem.setStockReceiver( stockReceiver );

				// Adding vendor to product/sku if no existing relationship
				var product = vendorOrderItem.getSku().getProduct();
				if (!arguments.vendorOrder.getVendor().hasProduct(product)) {
					// Add vendor product relationship
					arguments.vendorOrder.getVendor().addProduct(product);
					newVendorProductPreferenceFlag = true;
				}
				
			}
		}
		var closedFlag = true;
		var partiallyReceivedFlag = false;
		
		for(var vendorOrderItem in arguments.vendorOrder.getVendorOrderItems()) {
			if(vendorOrderItem.getQuantityUnreceived() > 0) {
				closedFlag = false;
			}
			if(vendorOrderItem.getQuantityReceived() > 0) {
				partiallyReceivedFlag = true;
			}
		}
		// Change the status depending on what value the partiallyReceivedFlag or closedFlag
		if(closedFlag){
			arguments.vendorOrder.setVendorOrderStatusType( getTypeService().getTypeBySystemCode("vostClosed") );
		} else if(partiallyReceivedFlag) {
			arguments.vendorOrder.setVendorOrderStatusType( getTypeService().getTypeBySystemCode("vostPartiallyReceived") );

		}
		arguments.vendorOrder = this.saveVendorOrder(arguments.vendorOrder);
		
		// Persist and update vendor products if necessary
		if (newVendorProductPreferenceFlag) {
			getVendorService().saveVendor(arguments.vendorOrder.getVendor());
		}

		return arguments.vendorOrder;
	}
	
	// =====================  END: Process Methods ============================
	
	// ====================== START: Status Methods ===========================
	
	// ======================  END: Status Methods ============================
	
	// ====================== START: Save Overrides ===========================
	
	// ======================  END: Save Overrides ============================
	
	// ==================== START: Smart List Overrides =======================
	
	// ====================  END: Smart List Overrides ========================
	
	// ====================== START: Get Overrides ============================
	
	// ======================  END: Get Overrides =============================
	
}

