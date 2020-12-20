USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Seminar].[WEB_MAIL_CONFIRM_SELECT]
	@ID	UNIQUEIDENTIFIER = NULL
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
		DECLARE
			@Status_Id	UniqueIdentifier;

		SET @Status_Id = (SELECT TOP (1) ID FROM Seminar.Status WHERE INDX = 1);

		SELECT
			a.ID, a.PSEDO,
			a.EMAIL,
			--'denisov@bazis' AS EMAIL,
			d.NAME, b.DATE, b.TIME,
			'Запись на вебинар' AS SUBJ,
			'no-reply@kprim.ru' AS FROM_ADDRESS,
			'ООО Базис' AS FROM_NAME,
			/*
			'<html>
			<head>
			</head>
			<body>
				<div style="font-size:16">
					Здравствуйте, ' + a.PSEDO + '! Вы получили это письмо, потому что записались на семинар "' + d.NAME + '", который пройдет ' + CONVERT(VARCHAR(20), DATEPART(DAY, b.DATE)) + ' ' + e.ROD + ' (' + DATENAME(WEEKDAY, b.DATE) + ') в офисе ООО "Базис" по адресу г.Владивосток, пр-т Острякова, д.8
				</div>
				<br/>
				<div style="font-size:16">
					Для того, чтобы подтвердить свое участие, перейдите по <a href="http://86.102.88.244/seminar/?type=confirm&id=' + CONVERT(VARCHAR(64), a.ID) + '" target="_blank"> этой ссылке </a>
				</div>
				<br/>
				<div style="font-size:12">
					Данное письмо сформировано автоматически, не отвечайте на него. Если у Вас есть вопросы, обратитесь к обслуживающему Вас специалисту или по телефону 24-25-600.
				</div>
			</body>
			</html>' AS MAIL_BODY
			*/
            '<html>
			<head>
			</head>
			<body>
				<div style="font-size:16">
					Здравствуйте, ' + a.PSEDO + '! Вы зарегистрированы на  вебинар "' + d.NAME + '", который  проводится компанией Базис с использованием программы ZOOM, ' + CONVERT(VARCHAR(20), DATEPART(DAY, b.DATE)) + ' ' + e.ROD + ' ' + CONVERT(VARCHAR(20), DATEPART(YEAR, b.DATE)) + ' года в ' + LEFT(CONVERT(NVARCHAR(MAX), b.TIME, 108), 5) + '.
				</div>
				<div style="font-size:16">
					Регистрация участников с 9-45 до 10-00.
				</div>
				<br/>
				<div style="font-size:16">
				    Для участия ZOOM – семинаре, вам необходимо кликнуть по ссылке <a href="https://us02web.zoom.us/j/85000182263" target="_blank">https://us02web.zoom.us/j/85000182263</a>, полученной от организатора или ввести ее в адресную строку браузера.
				</div>
				<br/>
				<div style="font-size:16">
				    Если у вас не установлена программа ZOOM, то вам будет предложена ее автоматическая установка.
                    Если возникли проблемы, заходите   в  группу   whatsapp "Базис-семинары"
                    по ссылке <a href="https://chat.whatsapp.com/DrAAmkwRlsE0MB0H6GKbe5" target="_blank">https://chat.whatsapp.com/DrAAmkwRlsE0MB0H6GKbe5</a>
				</div>
				<br/>
				<div style="font-size:12">
					Данное письмо сформировано автоматически, не отвечайте на него.
				</div>
				<div style="font-size:12">
					Если у Вас есть вопросы, обратитесь к обслуживающему Вас специалисту или по телефону 24-25-600.
				</div>
			</body>
			</html>' AS MAIL_BODY
		FROM
			Seminar.Personal a
			INNER JOIN Seminar.Schedule b ON a.ID_SCHEDULE = b.ID
			INNER JOIN Seminar.Subject d ON b.ID_SUBJECT = d.ID
			INNER LOOP JOIN dbo.Month e ON DATEPART(MONTH, b.DATE) = e.NUM
		WHERE b.WEB = 1 AND a.PSEDO IS NOT NULL AND a.EMAIL IS NOT NULL
			AND a.ID_STATUS = @Status_Id
			AND a.STATUS = 1

			AND
				(
					a.ID = @ID
					OR
					@ID IS NULL
					AND a.CONFIRM_SEND IS NULL
					AND GETDATE() > b.INVITE_DATE
				)
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Seminar].[WEB_MAIL_CONFIRM_SELECT] TO rl_seminar_web;
GO