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

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type ScanInputType = {
        databaseName: Text;
        tableName: Text;
        filterExpressions: [ SearchTypes.FilterExpressionType ];
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type AddAttributeInputType = {
        databaseName : Text;
        tableName : Text;
        attribute : Database.AttributeMetadata;
    };

    public type UpdateItemInputType = {
        databaseName: Text;
        tableName: Text;
        id: Text;
        attributeDataValues: [ (Text, Datatypes.AttributeDataValue) ];
    };

    public type UpdateOpsInputType = {
        #CreateDatabaseInput : CreateDatabaseInputType;
        #CreateTableInput : CreateTableInputType;
        #AddAttributeInput : AddAttributeInputType;
        #CreateItemInput : CreateItemInputType;
        #UpdateItemInput : UpdateItemInputType;
    };

    public type QueryOpsInputType = {
        #GetTableMetadataInput : GetTableMetadataInputType;
        #GetItemByIdInput : GetItemByIdInputType;
        #ScanInput : ScanInputType;
    };

};