USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Import].[Client@Upload]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Import].[Client@Upload]  AS SELECT 1')
GO
ALTER PROCEDURE [Import].[Client@Upload]
	@File_Id				Int,
	@Row_Id					Int,
	@Company_Id				UniqueIdentifier,
	@PersonalAdd			Bit,
	@PhoneAdd				Bit,
	@InnAdd					Bit
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

	DECLARE
		@Data			Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	BEGIN TRY

		SET @Data =
		(
			SELECT
				[Company_Id],
				[Personal],
				[Phone],
				[Inn]
			FROM
			(
				SELECT
					[Company_Id],
					[Personal],
					[Phone],
					[Inn]
				FROM [Import].[File:Item] AS I
				CROSS APPLY [Import].[Client@Parse](I.[Data]) AS D
				WHERE I.[File_Id] = @File_Id
					AND I.[Row_Id] = @Row_Id
				---
				UNION ALL
				---
				SELECT
					@Company_Id,
					@PersonalAdd,
					@PhoneAdd,
					@InnAdd
			) AS D
			FOR XML RAW('item'), ROOT('root')
		);

		UPDATE [Import].[File:Item] SET
			[UploadData] = @Data
		WHERE [File_Id] = @File_Id
			AND [Row_Id] = @Row_Id;

	END TRY
	BEGIN CATCH
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
