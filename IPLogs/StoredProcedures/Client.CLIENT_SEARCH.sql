USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[CLIENT_SEARCH]
	@COURIER		INT				=	NULL,
	@MANAGER		INT				=	NULL,
	@STATUS			INT				=	NULL,
	@SERVICE_TYPE	INT				=	NULL,
	@SYSTEM			INT				=	NULL,
	@DISTR			INT				=	NULL,
	@NAME			VARCHAR(100)	=	NULL,
	@ADDRESS		VARCHAR(100)	=	NULL,
	@CLIENT			BIT				=	NULL,
	@DBF			BIT				=	NULL,
	@REG			BIT				=	NULL,
	@IP				BIT				=	NULL,
	@IPBEGIN		DATETIME		=	NULL,
	@IPEND			DATETIME		=	NULL,
	@RC				INT				=	NULL	OUTPUT
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

	    IF OBJECT_ID('tempdb..#ois') IS NOT NULL
		    DROP TABLE #ois

	    IF OBJECT_ID('tempdb..#dbf') IS NOT NULL
		    DROP TABLE #dbf

	    IF OBJECT_ID('tempdb..#reg') IS NOT NULL
		    DROP TABLE #reg

	    CREATE TABLE #ois
		    (
			    CL_ID INT PRIMARY KEY
		    )
	    CREATE TABLE #dbf
		    (
			    TO_ID INT PRIMARY KEY
		    )

	    CREATE TABLE #reg
		    (
			    RG_ID INT PRIMARY KEY
		    )

	    IF @CLIENT = 1
	    BEGIN
		    INSERT INTO #ois(CL_ID)
			    SELECT ClientID
			    FROM [PC275-SQL\ALPHA].ClientDB.dbo.ClientTable
			    WHERE STATUS = 1

		    IF @COURIER IS NOT NULL
			    DELETE FROM #ois
			    WHERE CL_ID NOT IN
				    (
					    SELECT ClientID
					    FROM [PC275-SQL\ALPHA].ClientDB.dbo.ClientTable
					    WHERE ClientServiceID = @COURIER AND STATUS = 1
				    )
    
		    IF @MANAGER IS NOT NULL
			    DELETE FROM #ois
			    WHERE CL_ID NOT IN
				    (
					    SELECT ClientID
					    FROM
						    [PC275-SQL\ALPHA].ClientDB.dbo.ClientTable
						    INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.ServiceTable ON ServiceID = ClientServiceID
					    WHERE STATUS = 1 AND ManagerID = @MANAGER
				    )
    
		    IF @STATUS IS NOT NULL
			    DELETE FROM #ois
			    WHERE CL_ID NOT IN
				    (
					    SELECT ClientID
					    FROM [PC275-SQL\ALPHA].ClientDB.dbo.ClientTable
					    WHERE StatusID = @STATUS AND STATUS = 1
				    )
    
		    IF @SERVICE_TYPE IS NOT NULL
			    DELETE FROM #ois
			    WHERE CL_ID NOT IN
				    (
					    SELECT ClientID
					    FROM [PC275-SQL\ALPHA].ClientDB.dbo.ClientTable
					    WHERE ServiceTypeID = @SERVICE_TYPE AND STATUS = 1
				    )
    
		    IF (@SYSTEM IS NOT NULL) OR (@DISTR IS NOT NULL)
			    DELETE FROM #ois
			    WHERE CL_ID NOT IN
				    (
					    SELECT ID_CLIENT
					    FROM [PC275-SQL\ALPHA].ClientDB.dbo.ClientDistrView WITH(NOEXPAND)
					    WHERE (SystemID = @SYSTEM OR @SYSTEM IS NULL)
						    AND (DISTR = @DISTR OR @DISTR IS NULL)
				    )
    
		    IF @NAME IS NOT NULL
			    DELETE FROM #ois
			    WHERE CL_ID NOT IN
				    (
					    SELECT ClientID
					    FROM [PC275-SQL\ALPHA].ClientDB.dbo.ClientTable
					    WHERE STATUS = 1
						    AND (
						    ClientFullName LIKE @NAME 
						    OR EXISTS
							    (
								    SELECT *
								    FROM [PC275-SQL\ALPHA].ClientDB.dbo.ClientNames
								    WHERE ID_CLIENT = ClientID
									    AND NAME LIKE @NAME
							    ))
				    )
    
		    IF @ADDRESS IS NOT NULL
			    DELETE FROM #ois
			    WHERE CL_ID NOT IN
				    (
					    SELECT ClientID
					    FROM
						    [PC275-SQL\ALPHA].ClientDB.dbo.ClientTable
						    INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.ClientAddressView ON CA_ID_CLIENT = ClientID
					    WHERE CA_STR LIKE @ADDRESS
						    AND STATUS = 1
				    )

		    IF @IP = 1
			    DELETE FROM #ois
			    WHERE CL_ID NOT IN
				    (
					    SELECT ID_CLIENT
					    FROM
						    [PC275-SQL\ALPHA].ClientDB.dbo.ClientDistrView z WITH(NOEXPAND) INNER JOIN
						    [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable y ON z.SystemID = y.SystemID INNER JOIN
						    dbo.ClientStatDetail x ON
										    x.CSD_SYS = y.SystemNumber
									    AND x.CSD_DISTR = z.DISTR
									    AND x.CSD_COMP = z.COMP
					    WHERE (ISNULL(CSD_START, CSD_END) >= @IPBEGIN OR @IPBEGIN IS NULL)
						    AND (ISNULL(CSD_START, CSD_END) <= @IPEND OR @IPEND IS NULL)
				    )
	    END

	    IF @DBF = 1
	    BEGIN
		    INSERT INTO #dbf(TO_ID)
			    SELECT TO_ID
			    FROM [PC275-SQL\DELTA].DBF.dbo.TOTable

		    IF @NAME IS NOT NULL
			    DELETE FROM #dbf
			    WHERE TO_ID NOT IN
				    (
					    SELECT TO_ID
					    FROM [PC275-SQL\DELTA].DBF.dbo.TOTable
					    WHERE TO_NAME LIKE @NAME
				    )
    
		    IF @ADDRESS IS NOT NULL
			    DELETE FROM #dbf
			    WHERE TO_ID NOT IN
				    (
					    SELECT TA_ID_TO
					    FROM
						    [PC275-SQL\DELTA].DBF.dbo.TOAddressTable
						    INNER JOIN [PC275-SQL\DELTA].DBF.dbo.StreetTable ON ST_ID = TA_ID_STREET
						    INNER JOIN [PC275-SQL\DELTA].DBF.dbo.CityTable ON CT_ID = ST_ID_CITY
					    WHERE ISNULL(CT_NAME, '') + ' ' + ISNULL(ST_NAME, '') + ' ' + ISNULL(TA_HOME, '') LIKE @ADDRESS
				    )
    
		    IF @COURIER IS NOT NULL
			    DELETE FROM #dbf
			    WHERE TO_ID NOT IN
				    (
					    SELECT TO_ID
					    FROM
						    [PC275-SQL\DELTA].DBF.dbo.TOTable
						    INNER JOIN [PC275-SQL\DELTA].DBF.dbo.CourierTable ON COUR_ID = TO_ID_COUR
						    INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.ServiceTable ON COUR_NAME LIKE '%' + ServiceName + '%'
					    WHERE ServiceID = @COURIER
				    )
    
		    IF @MANAGER IS NOT NULL
			    DELETE FROM #dbf
			    WHERE TO_ID NOT IN
				    (
					    SELECT TO_ID
					    FROM
						    [PC275-SQL\DELTA].DBF.dbo.TOTable
						    INNER JOIN [PC275-SQL\DELTA].DBF.dbo.CourierTable ON COUR_ID = TO_ID_COUR
						    INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.ServiceTable ON COUR_NAME LIKE '%' + ServiceName + '%'
					    WHERE ManagerID = @COURIER
				    )

		    IF (@SYSTEM IS NOT NULL) OR (@DISTR IS NOT NULL)
			    DELETE FROM #dbf
			    WHERE TO_ID NOT IN
				    (
					    SELECT TD_ID_TO
					    FROM
						    [PC275-SQL\DELTA].DBF.dbo.TODistrTable
						    INNER JOIN [PC275-SQL\DELTA].DBF.dbo.DistrTable ON DIS_ID = TD_ID_DISTR
						    INNER JOIN [PC275-SQL\DELTA].DBF.dbo.SystemTable a ON SYS_ID = DIS_ID_SYSTEM
						    INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable b ON SYS_REG_NAME = SystemBaseName
					    WHERE (SystemID = @SYSTEM OR @SYSTEM IS NULL)
						    AND (DIS_NUM = @DISTR OR @DISTR IS NULL)
				    )
    
		    IF @IP = 1
			    DELETE FROM #dbf
			    WHERE TO_ID NOT IN
				    (
					    SELECT TD_ID_TO
					    FROM
						    [PC275-SQL\DELTA].DBF.dbo.TODistrTable
						    INNER JOIN [PC275-SQL\DELTA].DBF.dbo.DistrTable ON DIS_ID = TD_ID_DISTR
						    INNER JOIN [PC275-SQL\DELTA].DBF.dbo.SystemTable a ON SYS_ID = DIS_ID_SYSTEM
						    INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable b ON SystemBaseName = SYS_REG_NAME
						    INNER JOIN dbo.ClientStatDetail ON CSD_DISTR = DIS_NUM
														    AND CSD_COMP = DIS_COMP_NUM
														    AND CSD_SYS = SystemNumber
					    WHERE (ISNULL(CSD_START, CSD_END) >= @IPBEGIN OR @IPBEGIN IS NULL)
						    AND (ISNULL(CSD_START, CSD_END) <= @IPEND OR @IPEND IS NULL)
				    )
	    END
    
	    IF @REG = 1
	    BEGIN
		    INSERT INTO #reg(RG_ID)
			    SELECT ID
			    FROM [PC275-SQL\ALPHA].ClientDB.dbo.RegNodeTable

		    IF @NAME IS NOT NULL
			    DELETE FROM #reg
			    WHERE RG_ID NOT IN
				    (
					    SELECT ID
					    FROM [PC275-SQL\ALPHA].ClientDB.dbo.RegNodeTable
					    WHERE Comment LIKE @NAME
				    )
    
		    IF (@SYSTEM IS NOT NULL) OR (@DISTR IS NOT NULL)
			    DELETE FROM #reg
			    WHERE RG_ID NOT IN
				    (
					    SELECT ID
					    FROM
						    [PC275-SQL\ALPHA].ClientDB.dbo.RegNodeTable a
						    INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable b ON b.SystemBaseName = a.SystemName
					    WHERE (SystemID = @SYSTEM OR @SYSTEM IS NULL)
						    AND (DistrNumber = @DISTR OR @DISTR IS NULL)
				    )

		    IF @IP = 1
			    DELETE FROM #reg
			    WHERE RG_ID NOT IN
				    (
					    SELECT ID
					    FROM
						    [PC275-SQL\ALPHA].ClientDB.dbo.RegNodeTable a
						    INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable b ON a.SystemName = b.SystemBaseName
						    INNER JOIN dbo.ClientStatDetail ON CSD_DISTR = DistrNumber
														    AND CSD_COMP = CompNumber
														    AND CSD_SYS = SystemNumber
					    WHERE (ISNULL(CSD_START, CSD_END) >= @IPBEGIN OR @IPBEGIN IS NULL)
						    AND (ISNULL(CSD_START, CSD_END) <= @IPEND OR @IPEND IS NULL)
				    )

		    IF @DISTR = 490
			    INSERT INTO #reg(RG_ID)
				    SELECT -1
	    END
    
	    SELECT
		    ClientID, ClientFullName, CA_STR AS ClientAdress, ServiceName, ManagerName, ServiceStatusIndex,
		    ServiceTypeName, 'OIS' AS ClientType
	    FROM
		    #ois
		    INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.ClientTable a ON CL_ID = a.ClientID
		    INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.ServiceTable b ON a.ClientServiceID = b.ServiceID
		    INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.ManagerTable c ON c.ManagerID = b.ManagerID
		    INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.ServiceStatusTable d ON a.StatusID = d.ServiceStatusID
		    INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.ServiceTypeTable e ON e.ServiceTypeID = a.ServiceTypeID
		    LEFT OUTER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.ClientAddressView f ON f.CA_ID_CLIENT = a.ClientID

	    UNION ALL
    
	    SELECT
		    t.TO_ID, TO_NAME,
		    (
			    SELECT TOP 1 ISNULL(CT_NAME, '') + ' ' + ST_NAME + ' ' + TA_HOME
			    FROM
				    [PC275-SQL\DELTA].DBF.dbo.TOAddressTable h INNER JOIN
				    [PC275-SQL\DELTA].DBF.dbo.StreetTable k ON k.ST_ID = h.TA_ID_STREET LEFT OUTER JOIN
				    [PC275-SQL\DELTA].DBF.dbo.CityTable l ON l.CT_ID = k.ST_ID_CITY
			    WHERE g.TO_ID = h.TA_ID_TO
			    ORDER BY TO_MAIN DESC
		    ), COUR_NAME, NULL, NULL, NULL, 'DBF'
		    FROM
			    #dbf t
			    INNER JOIN [PC275-SQL\DELTA].DBF.dbo.TOTable g ON t.TO_ID = g.TO_ID
			    INNER JOIN [PC275-SQL\DELTA].DBF.dbo.CourierTable m ON m.COUR_ID = TO_ID_COUR
    
	    UNION ALL

	    SELECT ID, Comment, NULL, NULL, NULL, NULL, NULL, 'REG'
	    FROM
		    #reg
		    INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.RegNodeTable p ON p.ID = RG_ID
	    WHERE RG_ID <> -1
    
	    UNION ALL

	    SELECT RG_ID, '–»÷ 490', NULL, NULL, NULL, NULL, NULL, 'REG'
	    FROM
		    #reg
	    WHERE RG_ID = -1

	    ORDER BY ClientFullName

	    SET @RC = @@ROWCOUNT

	    IF OBJECT_ID('tempdb..#ois') IS NOT NULL
		    DROP TABLE #ois

	    IF OBJECT_ID('tempdb..#dbf') IS NOT NULL
		    DROP TABLE #dbf

	    IF OBJECT_ID('tempdb..#reg') IS NOT NULL
		    DROP TABLE #reg

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Client].[CLIENT_SEARCH] TO rl_client_search;
GO
