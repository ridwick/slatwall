﻿<!---

    Slatwall - An e-commerce plugin for Mura CMS
    Copyright (C) 2011 ten24, LLC

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
    
    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
 
    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Notes:

--->
<cfset slatwallContent = getService("contentService").getContentByCmsContentID($.content("contentID"),true) />
<cfset slatwallProductSmartList = getService("productService").getSmartList(entityName="SlatwallProduct") />
<cfset slatwallProductSmartList.addFilter(propertyIdentifier="productType_systemCode", value="contentAccess") />
<cfset slatwallProducts = slatwallProductSmartList.getRecords() />
<cfoutput>
	<dl class="oneColumn">
		<cf_SlatwallPropertyDisplay object="#slatwallContent#" property="templateFlag" fieldName="slatwallData.templateFlag" edit="true">
		<cf_SlatwallPropertyDisplay object="#slatwallContent#" property="productListingFlag" fieldName="slatwallData.productListingFlag" edit="true">
		<cf_SlatwallPropertyDisplay object="#slatwallContent#" property="showProductInSubPagesFlag" fieldName="slatwallData.showProductInSubPagesFlag" edit="true">
		<cf_SlatwallPropertyDisplay object="#slatwallContent#" property="disableProductAssignmentFlag" fieldName="slatwallData.disableProductAssignmentFlag" edit="true">
		<cf_SlatwallPropertyDisplay object="#slatwallContent#" property="defaultProductsPerPage" fieldName="slatwallData.defaultProductsPerPage" edit="true">
		<cf_SlatwallPropertyDisplay object="#slatwallContent#" property="restrictAccessFlag" fieldName="slatwallData.restrictAccessFlag" edit="true">
		<cf_SlatwallPropertyDisplay object="#slatwallContent#" property="allowPurchaseFlag" fieldName="slatwallData.allowPurchaseFlag" edit="true">
		
		<!--- show all the skus for this content --->
		<cfif arrayLen(slatwallContent.getSkus())>
			<dt>
				<label>This Content is currently assigned to these skus:</label>
			</dt>
			<dd>
				<table>
					<tr>
						<th>Product</th>
						<th>Sku Code</th>
						<th>Price</th>
						<th></th>
					</tr>
					<cfloop array="#slatwallContent.getSkus()#" index="sku">
						<tr>
							<td><a href="/plugins/slatwall/?slatAction=product.edit&productID=#sku.getProduct().getProductID()#">#sku.getProduct().getProductName()#</a></td>
							<td>#sku.getSkuCode()#</td>
							<td>#sku.getPrice()#</td>
							<td><a href="" class="delete" /></td>
						</tr>					
					</cfloop>
				</table>
			</dd>
		</cfif>
		
		<!--- add new sku --->
		<dt>
			<label for="slatwallData.product.productID">Sell Access through an existing or new Product</label>
		</dt>
		<dd>
			<div>
				Product: 
				<div>
					<select name="slatwallData.product.productID">
						<option value="">New Product</option>
						<cfloop array="#slatwallProducts#" index="product">
							<option value="#product.getProductID()#">#product.getProductName()#</option>
						</cfloop>
					</select>
				</div>
			</div>
			</br>
			<div>
				Sku:
				<div>
					<select name="slatwallData.product.sku.skuID">
						<option value="">New Sku</option>
					</select>
				</div>	
			</div>
		</dd>
		<dt>
			<label for="slatwallData.product.price">Price</label>
		</dt>
		<dd>
			<input name="slatwallData.product.price" value="" />
		</dd>
	</dl>
</cfoutput>

<!--- remove this when slatwall scope is available in $ --->
<cffunction name="getService" access="private">
	<cfargument name="serviceName" /> 
	<cfreturn application.slatwall.pluginconfig.getApplication().getValue("serviceFactory").getBean(serviceName) />
</cffunction> 

<cfoutput>
<script type="text/javascript">
var $ = jQuery;
$(document).ready(function(){
	
	$('input[name="slatwallData.templateFlag"]').change(function(){
		if($(this).val() == 1){
			$('input[name="slatwallData.productListingFlag"]').filter('[value=0]').prop('checked', true).trigger('change');
			$('input[name="slatwallData.restrictAccessFlag"]').filter('[value=0]').prop('checked', true).trigger('change');
		}
	});
	
	$('input[name="slatwallData.productListingFlag"]').change(function(){
		if($(this).val() == 1){
			$('input[name="slatwallData.templateFlag"]').filter('[value=0]').prop('checked', true).trigger('change');
			$('input[name="slatwallData.restrictAccessFlag"]').filter('[value=0]').prop('checked', true).trigger('change');
			$('.productListingFlagRelated').show();
		} else {
			$('input[name="slatwallData.showProductInSubPagesFlag"]').filter('[value=0]').prop('checked', true).trigger('change');
			$('input[name="slatwallData.disableProductAssignmentFlag"]').filter('[value=0]').prop('checked', true).trigger('change');
			$('input[name="slatwallData.defaultProductsPerPage"]').val('');
			$('.productListingFlagRelated').hide();
		}
	});
	
	$('input[name="slatwallData.restrictAccessFlag"]').change(function(){
		if($(this).val() == 1){
			$('input[name="slatwallData.templateFlag"]').filter('[value=0]').prop('checked', true).trigger('change');
			$('input[name="slatwallData.productListingFlag"]').filter('[value=0]').prop('checked', true).trigger('change');
			$('.restrictAccessFlagRelated').show();
		} else {
			$('input[name="slatwallData.allowPurchaseFlag"]').filter('[value=0]').prop('checked', true).trigger('change');
			$('.restrictAccessFlagRelated').hide();
		}
	});
	
	$('input[name="slatwallData.allowPurchaseFlag"]').change(function(){
		if($(this).val() == 1){
			$('.allowPurchaseFlagRelated').show();
		} else {
			$('.allowPurchaseFlagRelated').hide();
		}
	});
	
	$('select[name="slatwallData.product.productID"]').change(function() {
		
		var postData = {
			apiKey: '#getService("sessionService").getAPIKey("sku", "get")#',
		};
		$.ajax({
			type: 'get',
			url: '/plugins/Slatwall/api/index.cfm/sku/smartlist/?F:product_productID='+$('select[name="slatwallData.product.productID"]').val(),
			data: postData,
			dataType: "json",
			success: function(r) {
				$('select[name="slatwallData.product.sku.skuID"]').html('');
				$('select[name="slatwallData.product.sku.skuID"]').append('<option value="">New Sku</option>');
				if(r.RECORDSCOUNT > 0){
					$.each(r.PAGERECORDS,function(index,value){
						var option = '<option value="'+value.skuID+'">$'+value.price+' - '+value.skuCode+'</option>';
						$('select[name="slatwallData.product.sku.skuID"]').append(option);
					});
				}
			}
		});
		
	});
	
	$('input[name="slatwallData.productListingFlag"]').trigger('change');
	$('input[name="slatwallData.restrictAccessFlag"]').trigger('change');
	$('input[name="slatwallData.allowPurchaseFlag"]').trigger('change');
	
});
</script>
</cfoutput>
