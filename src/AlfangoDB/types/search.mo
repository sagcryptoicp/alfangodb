import Datatypes "datatype";

module {

    type NumericAttributeDataValue = Datatypes.NumericAttributeDataValue;
    type StringAttributeDataValue = Datatypes.StringAttributeDataValue;
    type ListAttributeDataValue = Datatypes.ListAttributeDataValue;

    public type RelationalExpressionAttributeDataValue = NumericAttributeDataValue or StringAttributeDataValue or {
        #bool : Bool;
        #blob : Blob;
        #principal : Principal;
    };

    public type ContaintmentExpressionAttributeDataValue = StringAttributeDataValue or ListAttributeDataValue;

    public type FilterExpressionConditionType = {
        #EQ: RelationalExpressionAttributeDataValue;
        #NEQ: RelationalExpressionAttributeDataValue;
        #LT: RelationalExpressionAttributeDataValue;
        #LTE: RelationalExpressionAttributeDataValue;
        #GT: RelationalExpressionAttributeDataValue;
        #GTE: RelationalExpressionAttributeDataValue;
        #BEGINS_WITH: StringAttributeDataValue;
        #CONTAINS: ContaintmentExpressionAttributeDataValue;
        #NOT_CONTAINS: ContaintmentExpressionAttributeDataValue;
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