import Database "../types/database";
import Datatypes "../types/datatype";
import InputTypes "../types/input";
import OutputTypes "../types/output";
import SearchTypes "../types/search";
import Map "mo:map/Map";
import { thash } "mo:map/Map";
import Debug "mo:base/Debug";
import Prelude "mo:base/Prelude";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Blob "mo:base/Blob";
import Principal "mo:base/Principal";

module {

    type AttributeDataValue = Datatypes.AttributeDataValue;
    type NumericAttributeDataValue = Datatypes.NumericAttributeDataValue;
    type StringAttributeDataValue = Datatypes.StringAttributeDataValue;

    type RelationalExpressionAttributeDataValue = SearchTypes.RelationalExpressionAttributeDataValue;
    type FilterExpressionConditionType = SearchTypes.FilterExpressionConditionType;
    type FilterExpressionType = SearchTypes.FilterExpressionType;

    public func scan({
        scanInput : InputTypes.ScanInputType;
        alfangoDB : Database.AlfangoDB;
    }) : OutputTypes.ScanOutputType {

        // get databases
        let databases = alfangoDB.databases;

        let { databaseName; tableName; filterExpressions; } = scanInput;

        // check if database exists
        if (not Map.has(databases, thash, databaseName)) {
            let remark = "database does not exist: " # debug_show(databaseName);
            Debug.print(remark);
            return #err([ remark ]);
        };

        ignore do ?{
            let database = Map.get(databases, thash, databaseName)!;

            // check if table exists
            if (not Map.has(database.tables, thash, tableName)) {
                let remark = "table does not exist: " # debug_show(tableName);
                Debug.print(remark);
                return #err([ remark ]);
            };

            let table = Map.get(database.tables, thash, tableName)!;

            let tableItems = table.items;
            let filteredItemMap = Map.filter(tableItems, thash, func(itemId : Database.Id, item: Database.Item) : Bool {
                applyFilterExpression({ item; filterExpressions; });
            });

            let filterItemBuffer = Buffer.Buffer<{ id : Text; item: [(Text, Datatypes.AttributeDataValue)] }>(filteredItemMap.size());
            for (filteredItem in Map.vals(filteredItemMap)) {
                filterItemBuffer.add({
                    id = filteredItem.id;
                    item = Map.toArray(filteredItem.attributeDataValueMap);
                });
            };

            return #ok(Buffer.toArray(filterItemBuffer));
        };

        Prelude.unreachable();
    };

    private func applyFilterExpression({
        item: Database.Item;
        filterExpressions: [ FilterExpressionType ];
    }) : Bool {

        let attributeDataValueMap = item.attributeDataValueMap; 
        var filterExpressionResult = true;

        // iterate over filter expressions and apply them
        for (filterExpression in filterExpressions.vals()) {
            let { attributeName; filterExpressionCondition; } = filterExpression;

            var currentFilterExpressionResult = false;
            // check if attribute exists
            if (Map.has(attributeDataValueMap, thash, attributeName)) {
                ignore do? {
                    // apply filter expression condition when attribute exists
                    currentFilterExpressionResult := applyFilterExpressionCondition({
                        filterExpressionCondition;
                        attributeDataValue = Map.get(attributeDataValueMap, thash, attributeName)!;
                    });
                }
            }
            // if attribute does not exist, apply #NOT_EXISTS condition
            else if (filterExpressionCondition == #NOT_EXISTS) {
                currentFilterExpressionResult := true;
            };

            filterExpressionResult := filterExpressionResult and currentFilterExpressionResult;
        };

        return filterExpressionResult;
    };

    private func applyFilterExpressionCondition({
        filterExpressionCondition: FilterExpressionConditionType;
        attributeDataValue: AttributeDataValue;
    }) : Bool {

        switch (filterExpressionCondition) {
            case (#EQ(conditionAttributeDataValue)) {
                return applyFilterEQ({ attributeDataValue; conditionAttributeDataValue; });
            };
            case (#NEQ(conditionAttributeDataValue)) {
                return not applyFilterEQ({ attributeDataValue; conditionAttributeDataValue; });
            };
            case (#LT(conditionAttributeDataValue)) {
                return applyFilterLT({ attributeDataValue; conditionAttributeDataValue; });
            };
            case (#LTE(conditionAttributeDataValue)) {
                return applyFilterLTE({ attributeDataValue; conditionAttributeDataValue; });
            };
            case (#GT(conditionAttributeDataValue)) {
                return not applyFilterLTE({ attributeDataValue; conditionAttributeDataValue; });
            };
            case (#GTE(conditionAttributeDataValue)) {
                return not applyFilterLT({ attributeDataValue; conditionAttributeDataValue; });
            };
            case (#EXISTS) {
                return true;
            };
            case (#NOT_EXISTS) {
                return false;
            };
            case (#BEGINS_WITH(conditionAttributeDataValue)) {
                return applyFilterBEGINS_WITH({ attributeDataValue; conditionAttributeDataValue; });
            };
            case (#CONTAINS(conditionAttributeDataValue)) {
                return applyFilterCONTAINS({ attributeDataValue; conditionAttributeDataValue; });
            };
            case (#NOT_CONTAINS(conditionAttributeDataValue)) {
                return not applyFilterCONTAINS({ attributeDataValue; conditionAttributeDataValue; });
            };
            case (#IN(conditionAttributeDataValue)) {
                return applyFilterIN({ attributeDataValue; conditionAttributeDataValue; });
            };
            case (#BETWEEN(conditionAttributeDataValue)) {
                return applyFilterBETWEEN({ attributeDataValue; conditionAttributeDataValue; });
            };
            case (#NOT_BETWEEN(conditionAttributeDataValue)) {
                return not applyFilterBETWEEN({ attributeDataValue; conditionAttributeDataValue; });
            };
        };

        return false;
    };

    private func applyFilterEQ({
        attributeDataValue: AttributeDataValue;
        conditionAttributeDataValue: RelationalExpressionAttributeDataValue;
    }) : Bool {

        var areEqual = false;
        switch (conditionAttributeDataValue) {
            case (#int(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#int(attributeDataValue)) areEqual := inputDataValue == attributeDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int8(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#int8(attributeDataValue)) areEqual := inputDataValue == attributeDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int16(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#int16(attributeDataValue)) areEqual := inputDataValue == attributeDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int32(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#int32(attributeDataValue)) areEqual := inputDataValue == attributeDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int64(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#int64(attributeDataValue)) areEqual := inputDataValue == attributeDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#nat(attributeDataValue)) areEqual := inputDataValue == attributeDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat8(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#nat8(attributeDataValue)) areEqual := inputDataValue == attributeDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat16(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#nat16(attributeDataValue)) areEqual := inputDataValue == attributeDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat32(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#nat32(attributeDataValue)) areEqual := inputDataValue == attributeDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat64(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#nat64(attributeDataValue)) areEqual := inputDataValue == attributeDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#float(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#float(attributeDataValue)) areEqual := inputDataValue == attributeDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#text(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#text(attributeDataValue)) areEqual := inputDataValue == attributeDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#char(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#char(attributeDataValue)) areEqual := inputDataValue == attributeDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#bool(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#bool(attributeDataValue)) areEqual := inputDataValue == attributeDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#blob(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#blob(attributeDataValue)) areEqual := inputDataValue == attributeDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#principal(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#principal(attributeDataValue)) areEqual := inputDataValue == attributeDataValue;
                    case (_) Prelude.unreachable();
                };
            };
        };

        return areEqual;
    };

    private func applyFilterLT({
        attributeDataValue: AttributeDataValue;
        conditionAttributeDataValue: RelationalExpressionAttributeDataValue;
    }) : Bool {

        var isLessThan = false;
        switch (conditionAttributeDataValue) {
            case (#int(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#int(attributeDataValue)) isLessThan := attributeDataValue < inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int8(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#int8(attributeDataValue)) isLessThan := attributeDataValue < inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int16(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#int16(attributeDataValue)) isLessThan := attributeDataValue < inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int32(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#int32(attributeDataValue)) isLessThan := attributeDataValue < inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int64(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#int64(attributeDataValue)) isLessThan := attributeDataValue < inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#nat(attributeDataValue)) isLessThan := attributeDataValue < inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat8(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#nat8(attributeDataValue)) isLessThan := attributeDataValue < inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat16(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#nat16(attributeDataValue)) isLessThan := attributeDataValue < inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat32(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#nat32(attributeDataValue)) isLessThan := attributeDataValue < inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat64(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#nat64(attributeDataValue)) isLessThan := attributeDataValue < inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#float(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#float(attributeDataValue)) isLessThan := attributeDataValue < inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#text(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#text(attributeDataValue)) isLessThan := attributeDataValue < inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#char(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#char(attributeDataValue)) isLessThan := attributeDataValue < inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#bool(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#bool(attributeDataValue)) isLessThan := false;
                    case (_) Prelude.unreachable();
                };
            };
            case (#blob(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#blob(attributeDataValue)) isLessThan := attributeDataValue < inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#principal(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#principal(attributeDataValue)) isLessThan := attributeDataValue < inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
        };

        return isLessThan;
    };

    private func applyFilterLTE({
        attributeDataValue: AttributeDataValue;
        conditionAttributeDataValue: RelationalExpressionAttributeDataValue;
    }) : Bool {

        var isLessThanOrEqual = false;
        switch (conditionAttributeDataValue) {
            case (#int(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#int(attributeDataValue)) isLessThanOrEqual := attributeDataValue <= inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int8(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#int8(attributeDataValue)) isLessThanOrEqual := attributeDataValue <= inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int16(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#int16(attributeDataValue)) isLessThanOrEqual := attributeDataValue <= inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int32(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#int32(attributeDataValue)) isLessThanOrEqual := attributeDataValue <= inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int64(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#int64(attributeDataValue)) isLessThanOrEqual := attributeDataValue <= inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#nat(attributeDataValue)) isLessThanOrEqual := attributeDataValue <= inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat8(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#nat8(attributeDataValue)) isLessThanOrEqual := attributeDataValue <= inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat16(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#nat16(attributeDataValue)) isLessThanOrEqual := attributeDataValue <= inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat32(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#nat32(attributeDataValue)) isLessThanOrEqual := attributeDataValue <= inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat64(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#nat64(attributeDataValue)) isLessThanOrEqual := attributeDataValue <= inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#float(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#float(attributeDataValue)) isLessThanOrEqual := attributeDataValue <= inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#text(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#text(attributeDataValue)) isLessThanOrEqual := attributeDataValue <= inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#char(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#char(attributeDataValue)) isLessThanOrEqual := attributeDataValue <= inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#bool(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#bool(attributeDataValue)) isLessThanOrEqual := attributeDataValue == inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#blob(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#blob(attributeDataValue)) isLessThanOrEqual := attributeDataValue <= inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case (#principal(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#principal(attributeDataValue)) isLessThanOrEqual := attributeDataValue <= inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
        };

        return isLessThanOrEqual;
    };

    private func applyFilterBEGINS_WITH({
        attributeDataValue: AttributeDataValue;
        conditionAttributeDataValue: StringAttributeDataValue;
    }) : Bool {

        var beginsWith = false;
        switch (conditionAttributeDataValue) {
            case (#text(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#text(attributeDataValue)) beginsWith := Text.startsWith(attributeDataValue, #text inputDataValue);
                    case (_) Prelude.unreachable();
                };
            };
            case (#char(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#char(attributeDataValue)) beginsWith := attributeDataValue == inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
        };

        return beginsWith;
    };

    private func applyFilterCONTAINS({
        attributeDataValue: AttributeDataValue;
        conditionAttributeDataValue: StringAttributeDataValue;
    }) : Bool {

        var contains = false;
        switch (conditionAttributeDataValue) {
            case (#text(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#text(attributeDataValue)) contains := Text.contains(attributeDataValue, #text inputDataValue);
                    case (_) Prelude.unreachable();
                };
            };
            case (#char(inputDataValue)) {
                switch (attributeDataValue) {
                    case (#char(attributeDataValue)) contains := attributeDataValue == inputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
        };

        return contains;
    };

    private func applyFilterIN({
        attributeDataValue: AttributeDataValue;
        conditionAttributeDataValue:  [ RelationalExpressionAttributeDataValue ];
    }) : Bool {

        return Array.find<RelationalExpressionAttributeDataValue>(conditionAttributeDataValue, func(conditionAttributeDataValueInValue: RelationalExpressionAttributeDataValue) : Bool {
            applyFilterEQ({ attributeDataValue; conditionAttributeDataValue = conditionAttributeDataValueInValue; });
        }) != null;
    };

    private func applyFilterBETWEEN({
        attributeDataValue: AttributeDataValue;
        conditionAttributeDataValue: (RelationalExpressionAttributeDataValue, RelationalExpressionAttributeDataValue);
    }) : Bool {

        var isBetween = false;
        switch(conditionAttributeDataValue) {
            case ((#int(lowerInputDataValue), #int(upperInputDataValue))) {
                switch (attributeDataValue) {
                    case (#int(attributeDataValue)) isBetween := lowerInputDataValue <= attributeDataValue and attributeDataValue <= upperInputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#int8(lowerInputDataValue), #int8(upperInputDataValue))) {
                switch (attributeDataValue) {
                    case (#int8(attributeDataValue)) isBetween := lowerInputDataValue <= attributeDataValue and attributeDataValue <= upperInputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#int16(lowerInputDataValue), #int16(upperInputDataValue))) {
                switch (attributeDataValue) {
                    case (#int16(attributeDataValue)) isBetween := lowerInputDataValue <= attributeDataValue and attributeDataValue <= upperInputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#int32(lowerInputDataValue), #int32(upperInputDataValue))) {
                switch (attributeDataValue) {
                    case (#int32(attributeDataValue)) isBetween := lowerInputDataValue <= attributeDataValue and attributeDataValue <= upperInputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#int64(lowerInputDataValue), #int64(upperInputDataValue))) {
                switch (attributeDataValue) {
                    case (#int64(attributeDataValue)) isBetween := lowerInputDataValue <= attributeDataValue and attributeDataValue <= upperInputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#nat(lowerInputDataValue), #nat(upperInputDataValue))) {
                switch (attributeDataValue) {
                    case (#nat(attributeDataValue)) isBetween := lowerInputDataValue <= attributeDataValue and attributeDataValue <= upperInputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#nat8(lowerInputDataValue), #nat8(upperInputDataValue))) {
                switch (attributeDataValue) {
                    case (#nat8(attributeDataValue)) isBetween := lowerInputDataValue <= attributeDataValue and attributeDataValue <= upperInputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#nat16(lowerInputDataValue), #nat16(upperInputDataValue))) {
                switch (attributeDataValue) {
                    case (#nat16(attributeDataValue)) isBetween := lowerInputDataValue <= attributeDataValue and attributeDataValue <= upperInputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#nat32(lowerInputDataValue), #nat32(upperInputDataValue))) {
                switch (attributeDataValue) {
                    case (#nat32(attributeDataValue)) isBetween := lowerInputDataValue <= attributeDataValue and attributeDataValue <= upperInputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#nat64(lowerInputDataValue), #nat64(upperInputDataValue))) {
                switch (attributeDataValue) {
                    case (#nat64(attributeDataValue)) isBetween := lowerInputDataValue <= attributeDataValue and attributeDataValue <= upperInputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#float(lowerInputDataValue), #float(upperInputDataValue))) {
                switch (attributeDataValue) {
                    case (#float(attributeDataValue)) isBetween := lowerInputDataValue <= attributeDataValue and attributeDataValue <= upperInputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#text(lowerInputDataValue), #text(upperInputDataValue))) {
                switch (attributeDataValue) {
                    case (#text(attributeDataValue)) isBetween := lowerInputDataValue <= attributeDataValue and attributeDataValue <= upperInputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#char(lowerInputDataValue), #char(upperInputDataValue))) {
                switch (attributeDataValue) {
                    case (#char(attributeDataValue)) isBetween := lowerInputDataValue <= attributeDataValue and attributeDataValue <= upperInputDataValue;
                    case (_) Prelude.unreachable();
                };
            };
            case _ {
                Prelude.unreachable();
            }
        };

        return isBetween;
    };

};