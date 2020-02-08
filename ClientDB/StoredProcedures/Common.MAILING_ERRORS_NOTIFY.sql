USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Common].[MAILING_ERRORS_NOTIFY]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@Hours	SmallInt,
		@Cnt	Int,
		@Text	NVarChar(Max);

	SET @Hours = 2;

	SET @Cnt = 
		(
			SELECT COUNT(*)
			FROM Common.MailingLog
			WHERE Status = 1
				AND Date >= DateAdd(Hour, -@Hours, GetDate())
		);
		
	IF @Cnt > 0 BEGIN
		SET @Text = N'�� ���������� ' + Cast(@Hours AS NVarChar(20)) + N' ���� �������� ' + Cast(@Cnt AS NVarChar(20)) + N' ������. ��������� ������ ������������ ���������.';
		
		EXEC Maintenance.MAIL_SEND @Text = @Text;
	END;
END
