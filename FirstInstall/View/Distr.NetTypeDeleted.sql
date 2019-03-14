USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [Distr].[NetTypeDeleted] 
--WITH SCHEMABINDING
AS
	SELECT 
		NT_ID_MASTER, NT_ID, NT_NAME, NT_SHORT,
		NT_FULL, NT_COEF, NT_DATE, NT_END
	FROM 
		Distr.NetTypeAll a
	WHERE NT_REF = 3