USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_FINANCING_GET_PRODUCTS]
	@ID INT
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

		SELECT
			V.ProductGuid,
			V.ProductName,
			V.ProductPrice
		FROM dbo.ClientFinancing AS F
		CROSS APPLY
		(
			SELECT
				[ProductGuid] = c.value('(guid)[1]', 'Varchar(50)'),
				[ProductName] = c.value('(name)[1]', 'Varchar(50)'),
				[ProductPrice] = c.value('(price)[1]', 'Money')
			FROM F.EIS_DATA.nodes('(/export/contract/products/product)') AS E(C)
		) AS V
		WHERE ID_CLIENT = @ID;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_FINANCING_GET_PRODUCTS] TO rl_client_fin_r;
GO
