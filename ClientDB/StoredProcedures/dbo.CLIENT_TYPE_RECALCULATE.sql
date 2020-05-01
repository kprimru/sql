USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_TYPE_RECALCULATE]
	@Client_IDs	VarChar(Max)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @Clients Table
		(
			Id		Int		NOT NULL	Primary Key Clustered
		);

		INSERT INTO @Clients
		SELECT DISTINCT Item
		FROM dbo.GET_TABLE_FROM_LIST(@Client_IDs, ',');

		UPDATE C
		SET ClientTypeId = T.ClientTypeId
		FROM dbo.ClientTable	C
		INNER JOIN @Clients		U	ON C.ClientId = U.Id
		OUTER APPLY
		(
			SELECT R.ClientTypeId
			FROM dbo.ClientTypeAllView		T
			INNER JOIN dbo.ClientTypeTable	R ON R.ClientTypeName = T.CATEGORY
			WHERE T.ClientId = C.ClientId
		) T

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
