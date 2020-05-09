USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:		  ������� �������
��������:
*/

ALTER PROCEDURE [dbo].[SYSTEM_ADD]
	@prefix VARCHAR(20),
	@name VARCHAR(250),
	@shortname VARCHAR(50),
	@regname VARCHAR(50)  ,
	@hostid SMALLINT,
	@soid SMALLINT,
	@order SMALLINT,
	@report BIT,
	@code_1c VARCHAR(50),
	@code_1c2 VARCHAR(50),
	--@weight INT,
	@coef DECIMAL(8, 4),
	@IB	VARCHAR(10) = NULL,
	@calc	DECIMAL(4, 2),
	@active BIT,
	@psedo VARCHAR(50) = NULL, 
	@returnvalue BIT = 1
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

		INSERT INTO dbo.SystemTable
						(
							SYS_PREFIX, SYS_NAME, SYS_SHORT_NAME,
							SYS_REG_NAME, SYS_ID_HOST, SYS_ID_SO, SYS_ORDER,
							SYS_REPORT, SYS_PSEDO, SYS_ACTIVE, SYS_1C_CODE, SYS_1C_CODE2, SYS_COEF,
							SYS_IB, SYS_CALC
						)
		VALUES
				(
					@prefix, @name, @shortname, @regname,
					@hostid, @soid, @order, @report, @psedo,
					@active, @code_1c, @code_1c2, @coef, @IB, @calc
				)

		IF @returnvalue = 1
			SELECT SCOPE_IDENTITY() AS NEW_IDEN

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_ADD] TO rl_system_w;
GO