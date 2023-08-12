USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Mailing].[REQUEST_SEND_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Mailing].[REQUEST_SEND_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Mailing].[REQUEST_SEND_SELECT]
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
			[Email]			= E.[Email],
			[Subj]			= 'Клиент подписался на рассылку',
			[Body]			= 'Клиент "' + RN.Comment + '" (' + RN.DistrStr + ') подал заявку на подписку на рассылку на адрес "' + IsNull(R.[OriginalEMail], '') + '"'
		FROM [Mailing].[Requests]				AS R
		INNER JOIN [Reg].[RegNodeSearchView]	AS RN WITH(NOEXPAND) ON RN.[HostId] = R.[HostID] AND RN.[DistrNumber] = R.[Distr] AND RN.[CompNumber] = R.[Comp]
		INNER JOIN [dbo].[Subhost]				AS S ON RN.[SubhostName] = S.[SH_REG]
		INNER JOIN [dbo].[SubhostEmail]			AS E ON E.[Subhost_Id] = S.[SH_ID] AND E.[Type_Id] = (SELECT T.[Id] FROM [dbo].[SubhostEmail_Type] AS T WHERE T.[Code] = 'MAILING')
		WHERE R.[SendDate] IS NULL
			AND IsNull(E.[Email] ,'') != ''

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
