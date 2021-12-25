﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Mailing].[REQUEST_SEND_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Mailing].[REQUEST_SEND_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Mailing].[REQUEST_SEND_SELECT]
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

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Mailing].[REQUEST_SEND_SELECT] TO rl_mailing_req;
GO
