USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[TECHNOL_TYPE_EDIT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[TECHNOL_TYPE_EDIT]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Дата создания: 18.12.2008
Описание:	  Изменить данные о технологическом
               признаке с указанным кодом
*/

ALTER PROCEDURE [dbo].[TECHNOL_TYPE_EDIT]
	@id SMALLINT,
	@name VARCHAR(20),
	@reg SMALLINT,
	@coef DECIMAL(10, 4),
	@calc DECIMAL(4, 2),
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

		UPDATE dbo.TechnolTypeTable
		SET TT_NAME = @name,
			TT_REG = @reg,
			TT_COEF = @coef,
			TT_CALC = @calc,
			TT_ACTIVE = @active
		WHERE TT_ID = @id

		UPDATE t
		SET TTP_COEF = @coef
		FROM
			dbo.TechnolTypePeriod t
			INNER JOIN dbo.PeriodTable ON TTP_ID_PERIOD = PR_ID
		WHERE TTP_ID_TECH = @id AND PR_DATE > GETDATE()

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[TECHNOL_TYPE_EDIT] TO rl_technol_type_w;
GO
