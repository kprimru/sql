USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[IMPORT_ONLINE_DATA]
	@DATA		NVARCHAR(MAX),	
	@OUT_DATA	NVARCHAR(512) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @XML XML

	SET @XML = CAST(@DATA AS XML)
	
	DECLARE @ADD	INT
	
	SET @ADD = 0
	
	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

	INSERT INTO dbo.OnlineActivity(ID_HOST, DISTR, COMP, ID_WEEK, ACTIVITY, LGN)
		OUTPUT inserted.ID INTO @TBL
		SELECT HostID, DISTR, COMP, c.ID, ACTIVITY, LGN
		FROM
			(
				SELECT
					c.value('(@host)[1]', 'NVARCHAR(64)') AS HOST,
					c.value('(@login)[1]', 'NVARCHAR(64)') AS LGN,
					c.value('(@distr)[1]', 'INT') AS DISTR,
					c.value('(@comp)[1]', 'INT') AS COMP,
					c.value('(@activity)[1]', 'INT') AS ACTIVITY,
					CONVERT(SMALLDATETIME, c.value('(@week)[1]', 'NVARCHAR(64)'), 104) AS START
				FROM @XML.nodes('root/online') a(c)
			) AS a
			INNER JOIN dbo.Hosts b ON b.HostReg = a.HOST
			INNER JOIN Common.Period c ON c.START = a.START AND c.TYPE = 1
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.OnlineActivity z
				WHERE z.ID_HOST = b.HostID
					AND z.DISTR = a.DISTR
					AND z.COMP = a.COMP
					AND z.ID_WEEK = c.ID
					AND z.LGN = a.LGN
			)
	
	SET @ADD = @ADD + @@ROWCOUNT	
	
	SET @OUT_DATA = 'Добавлено ' + CONVERT(NVARCHAR(32), @ADD) + ' записей.'
END
