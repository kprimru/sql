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

ALTER PROCEDURE [dbo].[SYSTEM_NET_EDIT]
	@id INT,
	@name VARCHAR(20),
	@fullname VARCHAR(100),
	@coef DECIMAL(8, 4),
	@calc DECIMAL(4, 2),
	@order INT,
	@active BIT = 1
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

		UPDATE dbo.SystemNetTable
		SET SN_NAME = @name,
			SN_FULL_NAME = @fullname,
			SN_COEF = @coef,
			SN_ORDER = @order,
			SN_CALC = @calc,
			SN_ACTIVE = @active
		WHERE SN_ID = @id

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[SYSTEM_NET_EDIT] TO rl_system_net_w;
GO