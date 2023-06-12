USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[SEMINAR_ERRORS_NOTIFY]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[SEMINAR_ERRORS_NOTIFY]  AS SELECT 1')
GO
ALTER PROCEDURE [Seminar].[SEMINAR_ERRORS_NOTIFY]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE
			@Text	NVarChar(Max);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

        SET @Text = '';
        SELECT @Text = @Text +
                IsNull(T.[Name] + ' ', '') + '"' + J.NAME + '" ' + Convert(VarChar(20), S.Date, 104) + ' не имеет ссылку, необходимо настроить до того, как необходимо будет отправлять письма клиентам' + Char(10) + Char(13)
        FROM [Seminar].[Schedule] AS S
        INNER JOIN [Seminar].[Subject] AS J ON S.ID_SUBJECT = J.ID
		LEFT JOIN [Seminar].[Schedules->Types] AS T ON T.[Id] = S.[Type_Id]
        WHERE IsNull(Link, '') = ''
            AND DATE > DateAdd(Day, 7, GetDate())
            AND EXISTS
                (
                    SELECT *
                    FROM [Seminar].[Schedules->Types:Templates] AS T
                    WHERE T.[Type_Id] = S.[Type_Id]
                        AND T.[Data] LIKE '%{SeminarLink}%'
                );

		IF @Text != '' BEGIN
			EXEC [Common].[MAIL_SEND]
                @Recipients     = 'denisov@bazis;bateneva@bazis',
                @Subject        = 'Запись на семинар/вебинар. Предупреждения',
                @Body_Format    = 'TEXT',
                @Body           = @Text;
		END;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
