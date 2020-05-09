USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей
Дата создания:	20.10.2008
Описание:		Сохранить отчет. Если отчет с
					указанным именем уже существует,
					он будет перезаписан
Дата изменения:	03.03.2009
Описание:		Строка текста заменена на
					списки идентификаторов
*/

ALTER PROCEDURE [dbo].[REPORT_TEMPLATE_SAVE]
	@reporttemplatename VARCHAR(150),
	--  @reporttemplatetext VARCHAR(1000),
	@reporttype SMALLINT,
	@statuslist VARCHAR(MAX),
	@subhostlist VARCHAR(MAX),
	@systemlist VARCHAR(MAX),
	@systypelist VARCHAR(MAX),
	@nettypelist VARCHAR(MAX),
	@periodlist VARCHAR(MAX),
	@techtypelist VARCHAR(MAX),
	@totalric BIT,
	@totalcount BIT
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

		DECLARE @reporttemplateid SMALLINT

		SET @reporttemplateid = NULL

		SELECT @reporttemplateid = RT_ID
		FROM dbo.ReportTemplateTable
		WHERE RT_NAME = @reporttemplatename

		IF @reporttemplateid IS NULL
			BEGIN
				INSERT INTO dbo.ReportTemplateTable (
							RT_NAME, RT_ID_REPORT_TYPE,
							RT_LIST_STATUS, RT_LIST_SUBHOST, RT_LIST_SYSTEM,
							RT_LIST_SYSTYPE, RT_LIST_NETTYPE, RT_LIST_PERIOD,
							RT_LIST_TECHTYPE,
							RT_TOTALRIC,
							RT_TOTALCOUNT
							)
				VALUES		(
							@reporttemplatename, @reporttype,			--@reporttemplatetext
							@statuslist, @subhostlist, @systemlist,
							@systypelist, @nettypelist, @periodlist,
							@techtypelist,
							@totalric,
							@totalcount
							)
			END
		ELSE
			BEGIN
				UPDATE		dbo.ReportTemplateTable
				SET			RT_NAME = @reporttemplatename,		--RT_TEXT = @reporttemplatetext
							RT_ID_REPORT_TYPE = @reporttype,
							RT_LIST_STATUS = @statuslist,
							RT_LIST_SUBHOST = @subhostlist,
							RT_LIST_SYSTEM = @systemlist,
							RT_LIST_SYSTYPE = @systypelist,
							RT_LIST_NETTYPE = @nettypelist,
							RT_LIST_PERIOD = @periodlist,
							RT_LIST_TECHTYPE = @techtypelist,
							RT_TOTALRIC=@totalric,
							RT_TOTALCOUNT=@totalcount
				WHERE RT_ID = @reporttemplateid
			END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[REPORT_TEMPLATE_SAVE] TO rl_report_w;
GO