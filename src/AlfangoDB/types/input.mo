import Database "database";
import Datatypes "datatype";
import SearchTypes "search";

module {

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

    public type GetItemByIdInputType = {
        databaseName: Text;
        tableName: Text;
        id: Text;
    };

    public type ScanInputType = {
        databaseName: Text;
        tableName: Text;
        filters: [ SearchTypes.FilterExpressionType ];
    };

};