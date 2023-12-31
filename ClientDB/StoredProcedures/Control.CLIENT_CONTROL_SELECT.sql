USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Control].[CLIENT_CONTROL_SELECT]
	@CLIENT	INT
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
			a.ID, DATE, AUTHOR,
			NOTE, NOTIFY,
			ISNULL(b.NAME, RECEIVER) AS NAME,
			CONVERT(NVARCHAR(32), REMOVE_DATE, 104) + ' ' + CONVERT(NVARCHAR(32), REMOVE_DATE, 108) + ' / ' + REMOVE_USER AS REMOVE_DATA,
			CONVERT(BIT, 
			CASE
				WHEN REMOVE_DATE IS NOT NULL THEN 0
				WHEN REMOVE_AUTHOR = 1 AND ORIGINAL_LOGIN() = AUTHOR THEN 1
				WHEN RECEIVER = ORIGINAL_LOGIN() THEN 1
				WHEN b.PSEDO = 'MANAGER' AND IS_MEMBER('rl_control_manager') = 1 THEN 1
				WHEN b.PSEDO = 'LAW' AND IS_MEMBER('rl_control_law') = 1 THEN 1
				WHEN b.PSEDO = 'DUTY' AND IS_MEMBER('rl_control_duty') = 1 THEN 1
				WHEN b.PSEDO = 'AUDIT' AND IS_MEMBER('rl_control_audit') = 1 THEN 1
				WHEN b.PSEDO = 'CHIEF' AND IS_MEMBER('rl_control_chief') = 1 THEN 1
				WHEN b.PSEDO = 'TEACHER' AND IS_MEMBER('rl_control_teacher') = 1 THEN 1
				WHEN IS_SRVROLEMEMBER('sysadmin') = 1 OR IS_MEMBER('DBChief') = 1 THEN 1
				ELSE 0
			END) AS CAN_REMOVE,
			CASE
				WHEN REMOVE_AUTHOR = 1 AND REMOVE_GROUP = 1 THEN '����� + ������'
				WHEN REMOVE_AUTHOR = 0 AND REMOVE_GROUP = 1 THEN '������'
				WHEN REMOVE_AUTHOR = 1 AND REMOVE_GROUP = 0 THEN '�����'
				ELSE ''
			END AS REMOVE_INFO,
			REMOVE_NOTE
		FROM
			Control.ClientControl a
			LEFT OUTER JOIN Control.ControlGroup b ON a.ID_GROUP = b.ID
		WHERE ID_CLIENT = @CLIENT
		ORDER BY DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Control].[CLIENT_CONTROL_SELECT] TO rl_control_r;
GO
