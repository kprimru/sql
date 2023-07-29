USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[HotlineChat@Send Notifications]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[HotlineChat@Send Notifications]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[HotlineChat@Send Notifications]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE @DataToSend Table
	(
		[Chat_Id]		UniqueIdentifier,
		[Email]			VarChar(128),
		[Fio]			VarChar(128),
		[Subject_Id]	UniqueIdentifier,
		Primary Key Clustered([Chat_Id], [Subject_Id])
	);

	DECLARE @Result Table
	(
		[Email]			VarChar(128),
		[Fio]			VarChar(256),
		[Hotline_IDs]	VarChar(Max),
		[Subject_IDs]	VarChar(Max),
		[SeminarData]	VarChar(Max),
		Primary Key Clustered([Email])
	)

	DECLARE
		@Body			VarChar(Max),
		@Email			VarChar(128),
		@Fio			VarChar(256),
		@Hotline_IDs	VarChar(Max),
		@Subject_IDs	VarChar(Max),
		@SeminarData	VarChar(Max);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		INSERT INTO @DataToSend([Chat_Id], [Email], [Fio], [Subject_Id])
		SELECT HC.[ID], HC.[EMAIL], HC.[FIO], D.[Subject_Id]
		FROM [dbo].[HotlineChat] AS HC
		INNER JOIN [dbo].[HotlineChat=Process] AS P ON P.[Hotline_Id] = HC.[ID]
		CROSS APPLY
		(
			SELECT
				[Subject_Id]		= S.[ID]
			FROM [dbo].[HotlineChat:Demand] AS HCD
			INNER JOIN [Seminar].[SubjectDemand] AS SD ON SD.[Demand_Id] = HCD.[Demand_Id]
			INNER JOIN [Seminar].[Subject] AS S ON S.[ID] = SD.[Subject_Id]
			INNER JOIN [Seminar].[Schedule] AS SS ON SS.[ID_SUBJECT] = S.[ID]
			INNER JOIN [Seminar].[Schedules->Types] AS ST ON ST.[Id] = SS.[Type_Id]
			WHERE HCD.[HotlineChat_Id] = HC.[ID]
				--AND SS.[DATE] > GetDate()
				--AND SS.[WEB] = 1
			GROUP BY S.[ID] --S.[NAME], S.[ID], S.[NOTE]
		) AS D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM [Seminar].[SubjectNotification] AS N
				WHERE N.[Subject_Id] = D.[Subject_Id]
					AND N.[Email] = HC.[EMAIL]
					AND N.[Date] > DateAdd(Month, -3, GetDate())
			)
			AND P.[NotificationDate] IS NULL;



		INSERT INTO @Result([Email], [Fio], [Hotline_IDs], [Subject_IDs], [SeminarData])
		SELECT E.[Email], F.[Fio], H.[Hotline_IDs], H.[Subject_IDs], S.[SeminarData]
		FROM
		(
			SELECT DISTINCT [Email]
			FROM @DataToSend
		) AS E
		OUTER APPLY
		(
			SELECT TOP (1) F.[Fio]
			FROM @DataToSend AS F
			WHERE F.[Email] = E.[Email]
		) AS F
		OUTER APPLY
		(
			SELECT
				[Hotline_IDs] = String_Agg(Cast(H.[Chat_Id] AS VarChar(Max)), ','),
				[Subject_IDs] = String_Agg(Cast(H.[Subject_Id] AS VarChar(Max)), ',')
			FROM @DataToSend AS H
			WHERE H.[Email] = E.[Email]
		) AS H
		OUTER APPLY
		(
			SELECT
				[SeminarData] =
					'<table border=1>' +
				String_Agg(
				'<tr>' +
					'<td width=500>
						<span style=" font-family:''courier new''; font-size: 12pt;">
							<b>' + S.[SubjectName] + '</b>
						</span>
					</td>
					' /*
					<td width=500>
						<span style=" font-family:''courier new''; font-size: 12pt;">
							<div>' + S.[SubjectNote] + '</div>
						</span>
					</td>
					*/
					+ '
					<td width=200>
						' + S.[SeminarSchedule] + '
					</td>
				</tr>', '') + '</table>'
			FROM
			(
				SELECT DISTINCT
					[SubjectName]		= S.[NAME],
					[SubjectNote]		= S.[NOTE],
					[SeminarSchedule]	=
							'<table>' + String_agg('
								<tr>
									<td width=100>
										<span style=" font-family:''courier new''; font-size: 12pt;">
											' + ST.[Name] + '
										</span>
									</td>
									<td width=100>
										<span style=" font-family:''courier new''; font-size: 12pt;">
											' + Convert(VarChar(20), SS.[DATE], 104) + '
										</span>
									</td>
								</tr>', '') WITHIN GROUP (ORDER BY SS.[DATE]) + '
							</table>'
					--,
					--[SeminarType]	= ST.[Name],
					--[SeminarDate]	= SS.[DATE]
				FROM @DataToSend AS D
				INNER JOIN [Seminar].[Schedule] AS SS ON SS.[ID_SUBJECT] = D.[Subject_Id]
				INNER JOIN [Seminar].[Schedules->Types] AS ST ON ST.[Id] = SS.[Type_Id]
				INNER JOIN [Seminar].[Subject] AS S ON S.[ID] = D.[Subject_Id]
				WHERE D.[Email] = E.[Email]
					--AND SS.[WEB] = 1
					--AND SS.[DATE] > GetDate()
				GROUP BY S.[NAME], S.[NOTE]
			) AS S
		) AS S

		SET @Email = '';

		WHILE (1 = 1) BEGIN
			SELECT TOP (1)
				@Email = R.[Email],
				@Fio = R.[Fio],
				@Hotline_IDs = R.[Hotline_IDs],
				@Subject_IDs = R.[Subject_IDs],
				@SeminarData = R.[SeminarData]
			FROM @Result AS R
			WHERE R.[Email] > @Email
			ORDER BY
				R.[Email];

			IF @@RowCount < 1
				BREAK;

			SET @Body = '
			<span style=" font-family:''verdana''; font-size: 14pt; color: #514da1;">
							Здравствуйте, ' + @Fio + '
							<br>
					</span>
			<br>
			<br>
			<span style=" font-family:''verdana''; font-size: 14pt; color: #514da1;">
						По нашему скромному мнению, Вас могут заинтересовать семинары, которые в ближайшее время будут проходить на нашей платформе искусственного интеллекта и внеземного разума
					</span>
			<br>
			<br>
			<br>
			<br>
				' + @SeminarData + '

			<br>
			<br>
			Запись осуществляется на сайте <a href="https://kprim.ru/seminary-i-treningi/">kprim.ru</a>
			<br>
			<br>
			Данное письмо было сгенерировано автоматически. Не отвечайте на него, а то умрете через 100 лет'

			EXEC [Common].[MAIL_SEND]
				@Recipients				= 'denisov@bazis',--@Email
				@blind_copy_recipients	= null,
				@Subject				= N'ООО "Базис" информация о семинарах',
				@Body					= @Body,
				@Body_Format			= 'html',
				@FromAddress			= 'No-Reply of kprim.ru <no-reply@kprim.ru>';

			UPDATE [dbo].[HotlineChat=Process] SET
				[NotificationDate] = GetDate()
			WHERE [Hotline_Id] IN
				(
					SELECT S.[value]
					FROM String_Split(@Hotline_IDs, ',') AS S
				);

			INSERT INTO [Seminar].[SubjectNotification]([Subject_Id], [EMail], [Date])
			SELECT S.[value], @Email, GetDate()
			FROM String_Split(@Subject_IDs, ',') AS S;
		END

		--добавить даты с какой брать вопросы. Если больше 2-х месяцев до семинара спрашивал - то и не отправлять
		--А если прошло 3 месяца, а новых вопросов в чате не возникло, то предложить еще раз



		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
