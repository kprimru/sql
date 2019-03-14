USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
CREATE VIEW [dbo].[AuditTOVMIView]
AS
	SELECT CL_ID, CL_PSEDO, TO_ID, TO_NUM, TO_NAME, TO_VMI_COMMENT, 'Установлены только дополнительные системы' AS TO_ERROR
	FROM 
		dbo.TOTable INNER JOIN
		dbo.ClientTable ON CL_ID = TO_ID_CLIENT 
	WHERE NOT EXISTS
		(
			SELECT * 
			FROM 
				dbo.TODistrTable INNER JOIN
				dbo.DistrView ON DIS_ID = TD_ID_DISTR
			WHERE SYS_REPORT = 1 AND TD_ID_TO = TO_ID AND SYS_REG_NAME <> '-'
		) AND
		EXISTS
		(
			SELECT * 
			FROM 
				dbo.TODistrTable INNER JOIN
				dbo.DistrView ON DIS_ID = TD_ID_DISTR
			WHERE TD_ID_TO = TO_ID AND SYS_REG_NAME <> '-'
		)

	UNION ALL

	SELECT CL_ID, CL_PSEDO, TO_ID, TO_NUM, TO_NAME, TO_VMI_COMMENT, 'Все дистрибутивы переданы в другую ТО' AS TO_ERROR
	FROM 
		dbo.TOTable INNER JOIN
		dbo.ClientTable ON CL_ID = TO_ID_CLIENT 
	WHERE NOT EXISTS
		(
			SELECT * 
			FROM 
				dbo.TODistrTable INNER JOIN
				dbo.DistrView ON DIS_ID = TD_ID_DISTR
			WHERE TD_ID_TO = TO_ID AND SYS_REG_NAME <> '-'
		)

	UNION ALL

	SELECT CL_ID, CL_PSEDO, TO_ID, TO_NUM, TO_NAME, TO_VMI_COMMENT, '' AS TO_ERROR
	FROM 
		dbo.TOTable INNER JOIN
		dbo.ClientTable ON CL_ID = TO_ID_CLIENT 
	WHERE EXISTS
		(
			SELECT * 
			FROM 
				dbo.TODistrTable INNER JOIN
				dbo.DistrView ON DIS_ID = TD_ID_DISTR
			WHERE SYS_REPORT = 1 AND TD_ID_TO = TO_ID AND SYS_REG_NAME <> '-'
		) AND TO_VMI_COMMENT <> ''