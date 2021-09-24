USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[SYSTEM_EDIT]
	@id SMALLINT,
	@prefix VARCHAR(20),
	@name VARCHAR(250),
	@shortname VARCHAR(50),
	@regname VARCHAR(50),
	@hostid INT,
	@soid SMALLINT,
	@order SMALLINT,
	@report BIT,
	@code_1c VARCHAR(50),
	@code_1c2 VARCHAR(50),
	--@weight INT,
	@coef DECIMAL(4, 2),
	@ib VARCHAR(10),
	@calc DECIMAL(4, 2),
	@active BIT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		UPDATE dbo.SystemTable
		SET SYS_PREFIX = @prefix,
			SYS_NAME = @name,
			SYS_SHORT_NAME = @shortname,
			SYS_REG_NAME = @regname,
			SYS_ID_HOST = @hostid,
			SYS_ID_SO = @soid,
			SYS_ORDER = @order,
			SYS_REPORT = @report,
			SYS_ACTIVE = @active,
			SYS_1C_CODE = @code_1c,
			SYS_1C_CODE2 = @code_1c2,
			SYS_COEF = @coef,
			SYS_IB = @ib,
			SYS_CALC = @calc
		WHERE SYS_ID = @id

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[SYSTEM_EDIT] TO rl_system_w;
GO
