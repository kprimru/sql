USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reg].[DISTR_HISTORY_SELECT]
	@ID		UNIQUEIDENTIFIER	= NULL,
	@STR	VARCHAR(50)			= NULL OUTPUT,
	@HST	INT					= NULL,
	@DISTR	INT					= NULL,
	@COMP	TINYINT				= NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF @ID IS NOT NULL
		SELECT 
			@HST = HostID, @DISTR = DISTR, @COMP = COMP,
			@STR = DistrStr
		FROM dbo.ClientDistrView a WITH(NOEXPAND)
		WHERE ID = @ID
	ELSE
		SELECT @STR = DistrStr
		FROM 
			Reg.RegNodeSearchView a WITH(NOEXPAND)
			INNER JOIN dbo.SystemTable b ON a.SystemID = b.SystemID
		WHERE b.HostID = @HST AND DistrNumber = @DISTR AND CompNumber = @COMP

	SELECT b.DATE, b.SystemShortName, DS_NAME, SST_SHORT, NT_SHORT, TRAN_COUNT, TRAN_LEFT, REG_DATE, COMPLECT, COMMENT, CHANGES
	FROM 
		Reg.RegDistr a
		INNER JOIN Reg.RegHistoryView b WITH(NOEXPAND)ON a.ID = b.ID_DISTR
		/*INNER JOIN dbo.ClientSystemsTable c ON SystemDistrNumber = DISTR AND CompNumber = Comp
		INNER JOIN dbo.SystemTable d ON ID_HOST = HostID*/
		LEFT OUTER JOIN Reg.RegHistoryOperationView e ON e.ID = b.ID
	WHERE ID_HOST = @HST AND DISTR = @DISTR AND COMP = @COMP
	ORDER BY DATE DESC
END