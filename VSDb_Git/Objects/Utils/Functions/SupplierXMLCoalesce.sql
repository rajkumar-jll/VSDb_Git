
CREATE FUNCTION [Utils].[SupplierXMLCoalesce]
(
      @NumberOfPages INT
)
RETURNS @SupplierXMLList TABLE 
(
         PageNumber INT,
         XMLDoc VARCHAR(MAX)
) 
AS
--<CommentHeader>
/**********************************************************************************************************************

Properties
==========
FUNCTION NAME:  utils.XMLCoalesce
DESCRIPTION:    Combines multiple Supplier XMLs to a single XML, based on number of pages needed
AUTHOR:         Rileena Das
ORIGIN DATE:    19-Sept-2017

Additional Notes
================
REVISION HISTORY
=====================================================================================================================
Version       ChangeDate           Author BugRef Narrative
=======       ============  ====== ======= =============================================================================
001           19-Sept-2017  RD            TBC    Created
002           27-Sept-2017  MU            TBC           Added Created Date to XML file, Remove Less then equal to
003           09-Octo-2017  MU            TBC           remove utf-16 which comes with the new data .
004     17-NOV -2017 SM            TBC           Changed the Select clause according to the new XML           
**********************************************************************************************************************/
--</CommentHeader>
BEGIN
       declare       @SupplierXML varchar(max)
       declare @Counter int = 0
       --declare @NumberOfPages int =1
       DECLARE @SupplierXMLs TABLE
       (
         Id INT,
         PageNumber INT,
         XMLDoc XML, 
         CreatedDate DATETIMEOFFSET 
       ) 
       
       --! 1. Fetch the list of unprocessed Supplier XMLs posted by Proactis to ICRT end point 
       INSERT INTO @SupplierXMLs
                      (Id, PageNumber, XMLDoc,CreatedDate)
       SELECT
              Id, ROW_NUMBER() OVER (ORDER BY id) % @NumberOfPages AS page_number
              ,TRY_CAST(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(DocumentXml, '\',''), '"<?xml version="1.0" encoding="utf-8"?>', ''),'SRMSupplier','GetSupplierDetailsSupplier'),'"<?xml version="1.0" encoding="utf-16"?>', ''),'</GetSupplierDetailsSupplier>"','</GetSupplierDetailsSupplier>'),' xsi:nil="true" ','') AS XML)
              , CreatedOn
       FROM 
              dbo.ProactisRequests
       WHERE
              RequestTypeId = 4 and IsProcessed = 0
              AND DocumentXml LIKE '%supplier%';

       --! 2. Add a new node to store the  value of dbo.ProactisRequests.Id column
       UPDATE a
       SET XMLDoc.modify('insert <ProactisId>{sql:column("a.Id")}</ProactisId> into (GetSupplierDetailsSupplier)[1]') 
       FROM @SupplierXMLs AS a;

       UPDATE a
       SET XMLDoc.modify('insert <CreatedOn>{sql:column("a.CreatedDate")}</CreatedOn> into (GetSupplierDetailsSupplier)[1]') 
       FROM @SupplierXMLs AS a;
                 
       
       --! 3. Combine multiple XMLs into @NumberOfPages number of XMLs each wrapped in root tag <Suppliers> 
       WHILE @Counter <  @NumberOfPages
       BEGIN
              SELECT @SupplierXML = COALESCE(ISNULL(@SupplierXML,'') +  CHAR(13) + CHAR(10) , '') + CAST(ISNULL(XMLDoc,'') AS VARCHAR(MAX))
                      FROM @SupplierXMLs
                      WHERE PageNumber = @Counter;

              INSERT INTO @SupplierXMLList
                             (PageNumber, XMLDoc)
              VALUES (@Counter+1, '<Suppliers>' + @SupplierXML + '</Suppliers>');

              SET @Counter = @Counter + 1;
              SET @SupplierXML=''
       END 
       
       RETURN

END






