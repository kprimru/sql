USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Import].[Files@Select?Upload]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Import].[Files@Select?Upload]  AS SELECT 1')
GO
ALTER PROCEDURE [Import].[Files@Select?Upload]
	@File_Id		Int,
	@Row_Id			Int
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
			C.[Company_Id],
			C.[Personal],
			C.[Phone],
			C.[Inn],
			CC.[NUMBER]
		FROM [Import].[File:Item] AS I
		CROSS APPLY [Import].[Client@Parse](I.[UploadData]) AS C
		LEFT JOIN [Client].[Company] AS CC ON CC.[ID] = C.[Company_Id]
		WHERE I.[File_Id] = @File_Id
			AND I.[Row_Id] = @Row_Id
		ORDER BY I.[Row_Id]

	END TRY
	BEGIN CATCH
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Import].[Files@Select?Upload] TO rl_company_import;
GO
