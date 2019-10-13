USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[INNOVATION_CLIENT_APPLY]
	@INNOVATION	UNIQUEIDENTIFIER,
	@SYS_LIST	NVARCHAR(MAX),
	@CL_LIST	NVARCHAR(MAX) = NULL,
	@NET_LIST	NVARCHAR(MAX) = NULL,
	@TYPE_LIST	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client
		
	CREATE TABLE #client
		(
			ID INT PRIMARY KEY
		)
		
	IF @CL_LIST IS NOT NULL AND @CL_LIST <> ''
		INSERT INTO #client(ID)
			SELECT ID
			FROM dbo.TableIDFromXML(@CL_LIST) 
	ELSE IF @SYS_LIST IS NOT NULL OR @NET_LIST IS NOT NULL OR @TYPE_LIST IS NOT NULL
		INSERT INTO #client(ID)
			SELECT ClientID
			FROM dbo.ClientTable a
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
			WHERE STATUS = 1
				AND EXISTS
					(
						SELECT *
						FROM 
							dbo.ClientDistrView b WITH(NOEXPAND)
							INNER JOIN dbo.TableIDFromXML(@SYS_LIST) c ON c.ID = b.SystemID
							INNER JOIN dbo.TableIDFromXML(@NET_LIST) d ON d.ID = b.DistrTypeID
							INNER JOIN dbo.TableIDFromXML(@TYPE_LIST) e ON e.ID = b.SystemTypeID
						WHERE b.ID_CLIENT = a.ClientID AND b.DS_REG = 0
					)
	ELSE
		INSERT INTO #client(ID)
			SELECT ClientID
			FROM dbo.ClientTable a
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
			WHERE STATUS = 1
		
	INSERT INTO dbo.ClientInnovation(ID_CLIENT, ID_INNOVATION)
		SELECT ID, @INNOVATION
		FROM #client a
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.ClientInnovation b
				WHERE b.ID_CLIENT = a.ID
					AND ID_INNOVATION = @INNOVATION
			)
END
