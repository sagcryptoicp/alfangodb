import Datatypes "datatype";

module {

    type NumericAttributeDataValue = Datatypes.NumericAttributeDataValue;
    type StringAttributeDataValue = Datatypes.StringAttributeDataValue;

    public type RelationalExpressionAttributeDataValue = NumericAttributeDataValue or StringAttributeDataValue or {
        #bool : Bool;
        #blob : Blob;
        #principal : Principal;
    };

    public type FilterExpressionConditionType = {
        #EQ: RelationalExpressionAttributeDataValue;
        #NEQ: RelationalExpressionAttributeDataValue;
        #LT: RelationalExpressionAttributeDataValue;
        #LTE: RelationalExpressionAttributeDataValue;
        #GT: RelationalExpressionAttributeDataValue;
        #GTE: RelationalExpressionAttributeDataValue;
        #BEGINS_WITH: StringAttributeDataValue;
        #CONTAINS: StringAttributeDataValue;
        #NOT_CONTAINS: StringAttributeDataValue;
        #NOT_EXISTS;
        #EXISTS;
        #IN: [ RelationalExpressionAttributeDataValue ];
        #BETWEEN: (RelationalExpressionAttributeDataValue, RelationalExpressionAttributeDataValue);
        #NOT_BETWEEN: (RelationalExpressionAttributeDataValue, RelationalExpressionAttributeDataValue);
    };

    public type FilterExpressionType = {
        attributeName: Text;
        filterExpressionCondition: FilterExpressionConditionType;
    };

};