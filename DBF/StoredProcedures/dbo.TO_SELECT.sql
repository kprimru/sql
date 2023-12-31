USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:			������� �������
��������:		����� ���� ����� ������������ ���������� �������
*/

ALTER PROCEDURE [dbo].[TO_SELECT]
	@clientid INT,
	@distr INT = NULL
WITH EXECUTE AS OWNER
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

		IF DB_ID('DBF_NAH') IS NOT NULL
			SELECT
				TO_REPORT, TO_NUM, TO_NAME, TO_ID, COUR_NAME, TO_MAIN, TO_INN, CL_INN, TO_LAST, (SELECT COUNT(*) FROM DBF_NAH.dbo.TOTable z WHERE z.TO_NUM = a.TO_NUM) AS TO_NAH, TO_PARENT,
				ST_CITY_NAME + ', ' + TA_HOME AS TO_ADDRESS, TO_RANGE, TO_DELETED,
				L.[ExpireDate] AS TO_LOCK_EXPIRE
			FROM dbo.TOView a
			LEFT JOIN dbo.TOAddressView b ON a.TO_ID = b.TA_ID_TO
			OUTER APPLY
			(
			    SELECT TOP (1) L.[ExpireDate]
			    FROM [dbo].[TO:Locks] AS L
			    WHERE A.TO_ID = L.TO_Id
			        AND L.[DateTo] IS NULL
			) AS L
			WHERE TO_ID_CLIENT = @clientid
				AND
					(
						@distr IS NULL
						OR
						EXISTS
							(
								SELECT *
								FROM dbo.TODistrView
								WHERE DIS_NUM = @distr
									AND TD_ID_TO = TO_ID
							)
					)
			ORDER BY TO_NUM
		ELSE
			SELECT
				TO_REPORT, TO_NUM, TO_NAME, TO_ID, COUR_NAME, TO_MAIN, TO_INN, CL_INN, TO_LAST, 0 AS TO_NAH, TO_PARENT,
				ST_CITY_NAME + ', ' + TA_HOME AS TO_ADDRESS, TO_RANGE, TO_DELETED
			FROM
				dbo.TOView a
				LEFT OUTER JOIN dbo.TOAddressView b ON a.TO_ID = b.TA_ID_TO
			WHERE TO_ID_CLIENT = @clientid
				AND
					(
						@distr IS NULL
						OR
						EXISTS
							(
								SELECT *
								FROM dbo.TODistrView
								WHERE DIS_NUM = @distr
									AND TD_ID_TO = TO_ID
							)
					)
			ORDER BY TO_NUM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[TO_SELECT] TO rl_client_r;
GRANT EXECUTE ON [dbo].[TO_SELECT] TO rl_to_r;
GO
