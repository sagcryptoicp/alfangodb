import Database "database";
import Datatypes "datatype";
import SearchTypes "search";

module {

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type CreateDatabaseInputType = {
        name : Text;
    };

    public type CreateTableInputType = {
        databaseName : Text;
        name : Text;
        attributes : [ Database.AttributeMetadata ];
        indexes : [ Database.TableIndexMetadata ];
    };

    public type CreateItemInputType = {
        databaseName : Text;
        tableName : Text;
        attributeDataValues: [ (Text, Datatypes.AttributeDataValue) ];
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type GetTableMetadataInputType = {
        databaseName: Text;
        tableName: Text;
    };

    public type GetItemByIdInputType = {
        databaseName: Text;
        tableName: Text;
        id: Text;
    };

    public type BatchGetItemByIdInputType = {
        databaseName: Text;
        tableName: Text;
        ids: [ Text ];
    };

    public type GetItemCountInputType = {
        databaseName: Text;
        tableName: Text;
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type ScanInputType = {
        databaseName: Text;
        tableName: Text;
        filterExpressions: [ SearchTypes.FilterExpressionType ];
    };

    public type ScanAndGetIdsInputType = ScanInputType;

    public type PaginatedScanInputType = {
        databaseName: Text;
        tableName: Text;
        filterExpressions: [ SearchTypes.FilterExpressionType ];
        offset: Nat;
        limit: Nat;
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type AddAttributeInputType = {
        databaseName : Text;
        tableName : Text;
        attribute : Database.AttributeMetadata;
    };

    public type DropAttributeInputType = {
        databaseName : Text;
        tableName : Text;
        attributeName : Text;
    };

    public type UpdateItemInputType = {
        databaseName: Text;
        tableName: Text;
        id: Text;
        attributeDataValues: [ (Text, Datatypes.AttributeDataValue) ];
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type GetDatabasesInputType = {};

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type UpdateOpsInputType = {
        #CreateDatabaseInput : CreateDatabaseInputType;
        #CreateTableInput : CreateTableInputType;
        #AddAttributeInput : AddAttributeInputType;
        #DropAttributeInput : DropAttributeInputType;
        #CreateItemInput : CreateItemInputType;
        #UpdateItemInput : UpdateItemInputType;
    };

    public type QueryOpsInputType = {
        #GetTableMetadataInput : GetTableMetadataInputType;
        #GetItemByIdInput : GetItemByIdInputType;
        #BatchGetItemByIdInput : BatchGetItemByIdInputType;
        #GetItemCountInput : GetItemCountInputType;
        #ScanInput : ScanInputType;
        #ScanAndGetIdsInput : ScanAndGetIdsInputType;
        #PaginatedScanInput : PaginatedScanInputType;
        #GetDatabasesInput : GetDatabasesInputType;
    };

};