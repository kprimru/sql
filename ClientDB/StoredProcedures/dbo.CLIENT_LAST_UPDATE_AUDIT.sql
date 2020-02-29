USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_LAST_UPDATE_AUDIT]
	@SERVICE	INT,
	@MANAGER	INT,
	@DATE		SMALLDATETIME = NULL
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

		IF @SERVICE IS NOT NULL
			SET @MANAGER = NULL

		DECLARE @LAST_DATE	SMALLDATETIME

		SET @LAST_DATE = dbo.DateOf(GETDATE())

		DECLARE @Complect Table
		(
			UD_ID		Int,
			CL_ID		Int,
			UD_DISTR	Int,
			UD_COMP		TinyInt,
			UD_NAME		VarChar(100),
			Primary Key Clustered (UD_ID)
		)

		INSERT INTO @Complect(UD_ID, CL_ID, UD_DISTR, UD_COMP)
		SELECT D.UD_ID, ClientID, D.UD_DISTR, D.UD_COMP
		FROM
		(
			SELECT ClientID
			FROM dbo.ClientView a WITH(NOEXPAND)
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
			WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND EXISTS
					(
						SELECT *
						FROM dbo.ClientDistrView WITH(NOEXPAND)
						WHERE ID_CLIENT = ClientID 
							AND DS_REG = 0
							AND DistrTypeBaseCheck = 1
							AND SystemBaseCheck = 1
					)
		) C
		INNER JOIN USR.USRData D ON D.UD_ID_CLIENT = C.ClientID
		INNER JOIN USR.USRComplectCurrentStatusView S WITH(NOEXPAND) ON D.UD_ID = S.UD_ID
		WHERE UD_ACTIVE = 1 AND S.UD_SERVICE = 0;

		DELETE C
		FROM @Complect C
		WHERE EXISTS
			(
				SELECT *
				FROM USR.USRIBDateView U WITH(NOEXPAND)
				WHERE C.UD_ID = U.UD_ID
					AND C.CL_ID = U.UD_ID_CLIENT
					AND UIU_DATE_S BETWEEN DATEADD(WEEK, -3, @LAST_DATE) AND @LAST_DATE
			);
			
		IF @DATE IS NOT NULL
			DELETE C
			FROM @Complect C
			WHERE NOT EXISTS		
				(
					SELECT *
					FROM USR.USRIBDateView U WITH(NOEXPAND)
					WHERE C.UD_ID = U.UD_ID
						AND C.CL_ID = U.UD_ID_CLIENT
						AND UIU_DATE_S >= @DATE
				);

		UPDATE C
		SET UD_NAME = dbo.DistrString(f.SystemShortName, c.UD_DISTR, c.UD_COMP)
		FROM @Complect C
		CROSS APPLY
		(
			SELECT TOP 1 SystemShortName
			FROM USR.USRFile
			INNER JOIN dbo.SystemTable ON SystemID = UF_ID_SYSTEM
			WHERE UF_ID_COMPLECT = UD_ID AND UF_ACTIVE = 1
			ORDER BY UF_DATE DESC, UF_CREATE DESC
		) F;

		SELECT 
			ClientID, CLientFullName + ' (' + ServiceTypeShortName + ')' AS ClientFullName, UD_NAME, ServiceName, ManagerName, 
			(
				SELECT TOP 1 UIU_DATE_S
				FROM USR.USRIBDateView U WITH(NOEXPAND)
				WHERE A.UD_ID = U.UD_ID
					AND A.CL_ID = U.UD_ID_CLIENT
					AND UIU_DATE_S < @LAST_DATE
				ORDER BY UIU_DATE_S DESC
			) AS LAST_UPDATE,
			(
				SELECT CONVERT(VARCHAR(20), EventDate, 104) + ' ' + EventComment + CHAR(10)
				FROM EventTable z
				WHERE EventActive = 1 
					AND CL_ID = z.ClientID
					AND EventDate BETWEEN DATEADD(WEEK, -3, @LAST_DATE) AND @LAST_DATE
				ORDER BY EventDate FOR XML PATH('')
			) AS EventComment
		FROM 
			@Complect a
			INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON ClientID = CL_ID
			INNER JOIN dbo.ServiceTypeTable c ON b.ServiceTypeID = c.ServiceTypeID
		WHERE UD_NAME IS NOT NULL
		ORDER BY ManagerName, ServiceName, ClientFullName, UD_NAME
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

