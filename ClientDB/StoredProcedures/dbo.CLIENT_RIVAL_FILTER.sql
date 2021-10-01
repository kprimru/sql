USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_RIVAL_FILTER]
	@BEGIN			SMALLDATETIME,
	@END			SMALLDATETIME,
	@CONTROL		BIT,
	@CONTROL_BEGIN	SMALLDATETIME,
	@CONTROL_END	SMALLDATETIME,
	@RIVAL_TYPE		INT,
	@COMPLETE		TINYINT,
	@CLIENT			VARCHAR(200),
	@REACT_BEGIN	SMALLDATETIME,
	@REACT_END		SMALLDATETIME,
	@CLAIM			INT = NULL,
	@COMPARE		INT = NULL,
	@REJECT			INT = NULL,
	@PARTNER		INT = NULL
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
			ClientID, CR_DATE, ClientFullName, RivalTypeName, RS_NAME AS ServiceStatusName, CR_COMPLETE,
			CR_CONTROL, CR_CONTROL_DATE, CR_CONDITION,
			REVERSE(
				STUFF(
					REVERSE(
						(
							SELECT PositionTypeName + ','
							FROM
								dbo.ClientRivalPersonal a
								INNER JOIN dbo.PositionTypeTable b ON a.CRP_ID_PERSONAL = b.PositionTypeID
							WHERE a.CRP_ID_RIVAL = y.CR_ID
							ORDER BY PositionTypeName FOR XML PATH('')
						)
					), 1, 1, ''
				)
			) AS CR_PERSONAL,
			CRR.CRR_DATE,
			CRR.CRR_COMMENT,
			ServiceName, ManagerName,
			CRR.CRR_CREATE_USER AS CR_AUTHOR,
			CASE CR_CONTROL
				WHEN 1 THEN 'На контроле ' + CONVERT(VARCHAR(20), CR_CONTROL_DATE, 104)
				ELSE ''
			END AS CR_CONTROL_S,
			CASE CR_COMPLETE
				WHEN 1 THEN 'Отработана'
				ELSE 'Не отработана'
			END AS CR_COMPLETE_S,
			CRR_CLAIM, CRR_COMPARE, CRR_REJECT, CRR_PARTNER
		FROM [dbo].[ClientList@Get?Read]()
	    INNER JOIN dbo.ClientRival y ON WCL_ID = CL_ID
		INNER JOIN dbo.ClientView WITH(NOEXPAND) ON ClientID = CL_ID
		LEFT JOIN dbo.RivalTypeTable ON RivalTypeID = CR_ID_TYPE
		LEFT JOIN dbo.RivalStatus ON RS_ID = CR_ID_STATUS
		OUTER APPLY
		(
		    --ToDo - это можно кэшировать
		    SELECT
		        ISNULL(CONVERT(BIT,(
			        SELECT MAX(CONVERT(INT, CRR_CLAIM))
			        FROM dbo.ClientRivalReaction
			        WHERE CRR_ID_RIVAL = CR_ID
		        )), 0) AS CRR_CLAIM,
		        ISNULL(CONVERT(BIT,(
			        SELECT MAX(CONVERT(INT, CRR_COMPARE))
			        FROM dbo.ClientRivalReaction
			        WHERE CRR_ID_RIVAL = CR_ID
		        )), 0) AS CRR_COMPARE,
		        ISNULL(CONVERT(BIT,(
			        SELECT MAX(CONVERT(INT, CRR_REJECT))
			        FROM dbo.ClientRivalReaction
			        WHERE CRR_ID_RIVAL = CR_ID
		        )), 0) AS CRR_REJECT,
		        ISNULL(CONVERT(BIT,(
			        SELECT MAX(CONVERT(INT, CRR_PARTNER))
			        FROM dbo.ClientRivalReaction
			        WHERE CRR_ID_RIVAL = CR_ID
		        )), 0) AS CRR_PARTNER
		) AS V
		OUTER APPLY
		(
		    SELECT TOP 1 CRR_COMMENT, CRR_DATE, CRR_CREATE_USER
			FROM dbo.ClientRivalReaction
			WHERE CRR_ID_RIVAL = y.CR_ID AND CRR_ACTIVE = 1
			ORDER BY CRR_DATE DESC, CRR_ID DESC
		) AS CRR
		WHERE CR_ACTIVE = 1
			AND (CR_DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (CR_DATE <= @END OR @END IS NULL)
			AND (CR_CONTROL = @CONTROL OR @CONTROL = 0)
			AND (
					(CR_CONTROL_DATE >= @CONTROL_BEGIN AND @CONTROL = 1) OR @CONTROL_BEGIN IS NULL OR @CONTROL = 0
				)
			AND (
					(CR_CONTROL_DATE <= @CONTROL_END AND @CONTROL = 1) OR @CONTROL_END IS NULL OR @CONTROL = 0
				)
			AND (CR_ID_TYPE = @RIVAL_TYPE OR @RIVAL_TYPE IS NULL)
			AND (CR_COMPLETE = @COMPLETE OR @COMPLETE = 2)
			AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
			AND
				(
					(@REACT_BEGIN IS NULL OR @REACT_BEGIN IS NULL)
					OR
					EXISTS
						(
							SELECT *
							FROM dbo.ClientRivalReaction
							WHERE CRR_ID_RIVAL = y.CR_ID AND CRR_ACTIVE = 1
								AND (CRR_DATE >= @REACT_BEGIN OR @REACT_BEGIN IS NULL)
								AND (CRR_DATE <= @REACT_END OR @REACT_END IS NULL)
						)
				)
			AND (@CLAIM IS NULL OR @CLAIM = 0 OR @CLAIM = 1 AND CRR_CLAIM = 1 OR @CLAIM = 2 AND CRR_CLAIM = 0)
			AND (@COMPARE IS NULL OR @COMPARE = 0 OR @COMPARE = 1 AND CRR_COMPARE = 1 OR @COMPARE = 2 AND CRR_COMPARE = 0)
			AND (@REJECT IS NULL OR @REJECT = 0 OR @REJECT = 1 AND CRR_REJECT = 1 OR @REJECT = 2 AND CRR_REJECT = 0)
			AND (@PARTNER IS NULL OR @PARTNER = 0 OR @PARTNER = 1 AND CRR_PARTNER = 1 OR @PARTNER = 2 AND CRR_PARTNER = 0)
		ORDER BY CR_DATE DESC, ClientFullName, y.CR_ID DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_RIVAL_FILTER] TO rl_filter_rival;
GO
