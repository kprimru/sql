﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_PRODUCT_GROUP_TRY_DELETE]
	@SPG_ID	INT
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

		DECLARE @res INT
		DECLARE @txt VARCHAR(MAX)

		SET @res = 0
		SET @txt = ''


		SELECT @res AS RES, @txt AS TXT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Subhost].[SUBHOST_PRODUCT_GROUP_TRY_DELETE] TO rl_subhost_product_group_d;
GO
