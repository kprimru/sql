USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 18.12.2008
Описание:	  Добавить технологический признак
               в справочник
*/

ALTER PROCEDURE [dbo].[TECHNOL_TYPE_ADD]
	@name VARCHAR(50),
	@reg SMALLINT,
	@coef DECIMAL(10, 4),
	@calc DECIMAL(4, 2),
	@active BIT = 1,
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

		DECLARE @ID	SMALLINT

		INSERT INTO dbo.TechnolTypeTable(TT_NAME, TT_REG, TT_COEF, TT_CALC, TT_ACTIVE)
		VALUES (@name, @reg, @coef, @calc, @active)

		SET @ID = SCOPE_IDENTITY()

		IF @returnvalue = 1
			SELECT @ID AS NEW_IDEN

		INSERT INTO dbo.TechnolTypePeriod(TTP_ID_TECH, TTP_ID_PERIOD, TTP_COEF)
			SELECT @ID, PR_ID, @coef
			FROM dbo.PeriodTable

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[TECHNOL_TYPE_ADD] TO rl_technol_type_w;
GO
