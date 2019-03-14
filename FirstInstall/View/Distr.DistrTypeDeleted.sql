USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [Distr].[DistrTypeDeleted]
--WITH SCHEMABINDING
AS
	SELECT 
		DT_ID_MASTER, DT_ID, DT_NAME, 
		DT_SHORT, DT_REG, DT_DATE, DT_END
	FROM 
		Distr.DistrTypeAll a
	WHERE DT_REF = 3