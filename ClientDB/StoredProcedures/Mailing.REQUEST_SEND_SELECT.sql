USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Mailing].[REQUEST_SEND_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		[ID]			= R.[ID],
		[FromAddress]	= 'no-reply@kprim.ru', 
		[FromName]		= 'ООО Базис', 
		[Psedo]			= SH_NAME,
		[Email]			= SH_EMAIL,
		[Subj]			= 'Клиент подписался на рассылку',
		[Body]			= 'Клиент "' + RN.Comment + '" (' + RN.DistrStr + ') подал заявку на подписку на рассылку на адрес "' + IsNull(R.[OriginalEMail], '') + '"'
	FROM Mailing.Requests R
	INNER JOIN Reg.RegNodeSearchView RN WITH(NOEXPAND) ON RN.HostId = R.HostID AND RN.DistrNumber = R.Distr AND RN.CompNumber = R.Comp
	INNER JOIN dbo.Subhost S ON RN.SubhostName = S.SH_REG
	WHERE R.SendDate IS NULL
		AND SH_EMAIL != ''
END
