import InputTypes "types/input";
import OutputTypes "types/output";
import Create "modules/create";
import Read "modules/read";
import Update "modules/update";
import Search "modules/search";
import Database "types/database";

module {

    public func updateOperation({
        updateOpsInput : InputTypes.UpdateOpsInputType;
        alfangoDB: Database.AlfangoDB;
    }) : async OutputTypes.UpdateOpsOutputType {

        switch (updateOpsInput) {
            case (#CreateDatabaseInput(createDatabaseInput)) {
                return #CreateDatabaseOutput(Create.createDatabase({ createDatabaseInput; alfangoDB; }));
            };
            case (#CreateTableInput(createTableInput)) {
                return #CreateTableOutput(Create.createTable({ createTableInput; alfangoDB; }));
            };
            case (#AddAttributeInput(addAttributeInput)) {
                return #AddAttributeOutput(Update.addAttribute({ addAttributeInput; alfangoDB; }));
            };
            case (#DropAttributeInput(dropAttributeInput)) {
                return #DropAttributeOutput(Update.dropAttribute({ dropAttributeInput; alfangoDB; }));
            };
            case (#CreateItemInput(createItemInput)) {
                return #CreateItemOutput(await Create.createItem({ createItemInput; alfangoDB; }));
            };
            case (#UpdateItemInput(updateItemInput)) {
                return #UpdateItemOutput(Update.updateItem({ updateItemInput; alfangoDB; }));
            };
        };

    };

    public func queryOperation({
        queryOpsInput : InputTypes.QueryOpsInputType;
        alfangoDB: Database.AlfangoDB;
    }) : OutputTypes.QueryOpsOutputType {

        switch (queryOpsInput) {
            case (#GetTableMetadataInput(getTableMetadataInput)) {
                return #GetTableMetadataOutput(Read.getTableMetadata({ getTableMetadataInput; alfangoDB; }));
            };
            case (#GetItemByIdInput(getItemByIdInput)) {
                return #GetItemByIdOutput(Read.getItemById({ getItemByIdInput; alfangoDB; }));
            };
            case (#BatchGetItemByIdInput(batchGetItemByIdInput)) {
                return #BatchGetItemByIdOutput(Read.batchGetItemById({ batchGetItemByIdInput; alfangoDB; }));
            };
            case (#GetItemCountInput(getItemCountInput)) {
                return #GetItemCountOutput(Read.getItemCount({ getItemCountInput; alfangoDB; }));
            };
            case (#ScanInput(scanInput)) {
                return #ScanOutput(Search.scan({ scanInput; alfangoDB; }));
            };
            case (#ScanAndGetIdsInput(scanAndGetIdsInput)) {
                return #ScanAndGetIdsOutput(Search.scanAndGetIds({ scanAndGetIdsInput; alfangoDB; }));
            };
            case (#PaginatedScanInput(paginatedScanInput)) {
                return #PaginatedScanOutput(Search.paginatedScan({ paginatedScanInput; alfangoDB; }));
            };
            case (#GetDatabasesInput(getDatabasesInput)){
                return #GetDatabasesOutput(Read.getDatabaseInfo(alfangoDB));
            };
        }
    }
};