USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Seminar].[WEB_MAIL_PROFILE_SELECT]
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
			'������ �� �������' AS SUBJ,
			'no-reply@kprim.ru' AS FROM_ADDRESS,
			'��� �����' AS FROM_NAME,
			/*
			'<html>
			<head>
			</head>
			<body>
				<div style="font-size:16">
					������������, ' + a.PSEDO + '! �� �������� ��� ������, ������ ��� ���������� �� ������� "' + d.NAME + '", ������� ������� ' + CONVERT(VARCHAR(20), DATEPART(DAY, b.DATE)) + ' ' + e.ROD + ' (' + DATENAME(WEEKDAY, b.DATE) + ') � ����� ��� "�����" �� ������ �.�����������, ��-� ���������, �.8
				</div>
				<br/>
				<div style="font-size:16">
					��� ����, ����� ����������� ���� �������, ��������� �� <a href="http://86.102.88.244/seminar/?type=confirm&id=' + CONVERT(VARCHAR(64), a.ID) + '" target="_blank"> ���� ������ </a>
				</div>
				<br/>
				<div style="font-size:12">
					������ ������ ������������ �������������, �� ��������� �� ����. ���� � ��� ���� �������, ���������� � �������������� ��� ����������� ��� �� �������� 24-25-600.
				</div>
			</body>
			</html>' AS MAIL_BODY
			*/
            '<html>
			<head>
			</head>
			<body>
				<div style="font-size:16">
					������������, ' + a.PSEDO + '!  ���������� ��� �� ������� � � ����� ����������������� ����������� � ���������� ���������, ������ ��� �������� �� ������� ����� ������.
				</div>
				<div style="font-size:16">
					��� ���������� ������ ��������� �� ������:
					<br/>
                    <a href="https://forms.yandex.ru/u/5fbcaa7b79e1e9cf12c8f9c9/" target="_blank">https://forms.yandex.ru/u/5fbcaa7b79e1e9cf12c8f9c9/</a>
				</div>
				<br/>
				<div style="font-size:12">
					������ ������ ������������ �������������, �� ��������� �� ����.
				</div>
				<div style="font-size:12">
					���� � ��� ���� �������, ���������� � �������������� ��� ����������� ��� �� �������� 24-25-600.
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
					AND a.PROFILE_DATE IS NULL
					AND GETDATE() > b.PROFILE_DATE
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
GRANT EXECUTE ON [Seminar].[WEB_MAIL_PROFILE_SELECT] TO rl_seminar_web;
GO