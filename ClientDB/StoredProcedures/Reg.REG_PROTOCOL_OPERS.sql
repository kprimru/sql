USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reg].[REG_PROTOCOL_OPERS]
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

		SELECT DISTINCT RPR_OPER
		FROM dbo.RegProtocol
		WHERE RPR_OPER NOT LIKE '"%'
			AND RPR_OPER NOT LIKE 'Добавлен в комплект%'
			AND RPR_OPER NOT LIKE 'Изменен email%'
			AND RPR_OPER NOT LIKE 'Изменен атрибут%'
			AND RPR_OPER NOT LIKE 'Изменен обслуживающий субъект%'
			AND RPR_OPER NOT LIKE 'Изменен комментарий%'
			AND RPR_OPER NOT LIKE 'Изменен доп. параметр%'
			AND RPR_OPER NOT LIKE 'Изменен номер телефона%'
			AND RPR_OPER NOT LIKE 'Изменен техн. тип%'
			AND RPR_OPER NOT LIKE 'Изменена дата%'
			AND RPR_OPER NOT LIKE 'Изменен УП%'
			AND RPR_OPER NOT LIKE 'Изменена серия%'
			AND RPR_OPER NOT LIKE 'Изменена сетевитость%'
			AND RPR_OPER NOT LIKE 'Назначен комментарий%'
			AND RPR_OPER NOT LIKE 'Отвязан Yubikey%'
			AND RPR_OPER NOT LIKE 'Назначен Yubikey%'
			AND RPR_OPER NOT LIKE 'Привязан Yubikey%'
			AND RPR_OPER NOT LIKE 'Первая регистрация системы%'
			AND RPR_OPER NOT LIKE 'Изменена дата%'
			AND RPR_OPER NOT LIKE 'Увеличилось количество оставшихся привязок%'
			AND RPR_OPER NOT LIKE 'Изменен состав ИБ%'
			AND RPR_OPER NOT LIKE 'Дистрибутив переведен из%'
			AND RPR_OPER NOT LIKE 'Система%'
			
		UNION
		
		SELECT 'Изменен email'
			
		ORDER BY RPR_OPER
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
