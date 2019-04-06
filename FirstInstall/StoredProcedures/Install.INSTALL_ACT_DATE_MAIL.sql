USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Install].[INSTALL_ACT_DATE_MAIL]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @BODY NVARCHAR(MAX)

	SET @BODY = N''

	SELECT @BODY = @BODY + 
		'Нет отметки о возврате акта "' + CL_NAME + '", установил "' + PER_NAME + '" ' +
		CONVERT(VARCHAR(20), IND_INSTALL_DATE, 104) + CHAR(13)
	FROM
		(
			SELECT DISTINCT CL_NAME, PER_NAME, IND_INSTALL_DATE, IA_NAME
			FROM Install.InstallFullView
			WHERE IND_INSTALL_DATE IS NOT NULL
				AND IA_NORM = 0
				AND DATEADD(DAY, 2, IND_INSTALL_DATE) < GETDATE()
				AND IND_ACT_MAIL IS NULL
		) AS o_O

	IF @BODY = N''
		RETURN

	EXEC msdb.dbo.sp_send_dbmail @profile_name = 'SQLMail',
				@recipients = N'moroz@bazis;denisov@bazis;gvv@bazis',				
				@body = @BODY,
				@subject='Отчет по неподписанных актах при установке'

	UPDATE Install.InstallDetail
	SET IND_ACT_MAIL = GETDATE()
	WHERE IND_ID IN
		(
			SELECT IND_ID
			FROM Install.InstallFullView
			WHERE IND_INSTALL_DATE IS NOT NULL
				AND IA_NORM = 0
				AND DATEADD(DAY, 2, IND_INSTALL_DATE) < GETDATE()
		)


END
