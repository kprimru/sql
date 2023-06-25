USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Import].[Files@Select?Client]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Import].[Files@Select?Client]  AS SELECT 1')
GO
ALTER PROCEDURE [Import].[Files@Select?Client]
	@File_Id		Int
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	BEGIN TRY

		SELECT
			I.[Row_Id],
			C.[CompanyName],
			C.[LegalForm],
			C.[Inn],
			C.[Address],
			C.[Surname],
			C.[Name],
			C.[Patron],
			C.[Activity],
			C.[Phones],
			C.[Email]
		FROM [Import].[File:Item] AS I
		CROSS APPLY [Import].[Client@Parse Client](I.[Data]) AS C
		WHERE I.[File_Id] = @File_Id
		ORDER BY I.[Row_Id];

	END TRY
	BEGIN CATCH
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Import].[Files@Select?Client] TO rl_company_import;
GO
