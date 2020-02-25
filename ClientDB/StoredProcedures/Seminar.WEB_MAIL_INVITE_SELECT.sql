USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seminar].[WEB_MAIL_INVITE_SELECT]
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

		SELECT 
			a.ID, a.PSEDO, 
			a.EMAIL,
			--'denisov@bazis' AS EMAIL, 
			d.NAME, b.DATE, b.TIME,
			'������ �� �������' AS SUBJ, 
			'no-reply@kprim.ru' AS FROM_ADDRESS, 
			'��� �����' AS FROM_NAME, 
			'������������, ' + a.PSEDO + '! �� �������� ��� ������, ������ ��� ���������� �� ������� "' + d.NAME + '", ������� ������� ' + CONVERT(NVARCHAR(MAX), b.DATE, 104) + ' � ' + LEFT(CONVERT(NVARCHAR(MAX), b.TIME, 108), 5) + ' � ����� ��� "�����"' AS MAIL_BODY
		FROM 
			Seminar.Personal a
			INNER JOIN Seminar.Schedule b ON a.ID_SCHEDULE = b.ID
			INNER JOIN Seminar.Status c ON c.ID = a.ID_STATUS
			INNER JOIN Seminar.Subject d ON b.ID_SUBJECT = d.ID
		WHERE b.WEB = 1 AND a.PSEDO IS NOT NULL AND a.EMAIL IS NOT NULL		
			AND c.INDX = 1
			AND a.STATUS = 1		
			AND
				(
					a.ID = @ID 
					OR 
					@ID IS NULL 
					AND GETDATE() > b.INVITE_DATE
					-- ����� �� ���������� ����������� �� ��� ��������� ���������
					AND b.DATE > GETDATE()
					AND a.CONFIRM_STATUS = 1
					AND NOT EXISTS
						(
							SELECT *
							FROM Seminar.Invite z
							WHERE z.ID_PERSONAL = a.ID
						)
				)
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

