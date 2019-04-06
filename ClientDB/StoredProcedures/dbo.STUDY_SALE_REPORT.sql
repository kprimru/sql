USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STUDY_SALE_REPORT]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@MON_CNT	SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ClientID, ClientFullName, 
		REVERSE(STUFF(REVERSE(
			(
				SELECT TeacherName + ', '
				FROM 
					(
						SELECT DISTINCT TeacherName
						FROM 
							dbo.ClientStudy z
							INNER JOIN dbo.TeacherTable y ON z.ID_TEACHER = y.TeacherID
						WHERE STATUS = 1
							AND TEACHED = 1
							AND (DATE >= @BEGIN OR @BEGIN IS NULL)
							AND (DATE <= @END OR @END IS NULL)
							AND ID_PLACE IN (1, 2)
							AND z.ID_CLIENT = a.ID_CLIENT
					) AS o_O		
				ORDER BY TeacherName FOR XML PATH('')
			)
		), 1, 2, '')) AS TeacherName, 
		a.DATE,
		
		REVERSE(STUFF(REVERSE(
				(
					SELECT --y.RPR_OPER
					
						DistrStr + '(' + CONVERT(VARCHAR(20), dbo.DateOf(RPR_DATE), 104) +'): ' + 
							CASE y.RPR_OPER 
								WHEN 'НОВАЯ' THEN 'Допродажа: ' + ISNULL(NEW.SystemShortName, '') + ' (' + ISNULL(NEW.NT_SHORT, '') + ')'
								WHEN 'Включение' THEN 'Восстановление: ' + ISNULL(NEW.SystemShortName, '') + ' (' + ISNULL(NEW.NT_SHORT, '') + ')'
								WHEN 'Изм. парам.' THEN 'Замена: ' + 
									CASE 
										WHEN OLD.SystemShortName <> NEW.SystemShortName AND OLD.NT_SHORT <> NEW.NT_SHORT THEN 'с ' + OLD.SystemShortName + ' ' + OLD.NT_SHORT + ' на ' + NEW.SystemShortName + ' ' + NEW.NT_SHORT
										WHEN OLD.SystemShortName = NEW.SystemShortName AND OLD.NT_SHORT <> NEW.NT_SHORT THEN OLD.SystemShortName + ' с '+ OLD.NT_SHORT + ' на ' + NEW.NT_SHORT
										WHEN OLD.SystemShortName <> NEW.SystemShortName AND OLD.NT_SHORT = NEW.NT_SHORT THEN OLD.NT_SHORT + ' c ' + OLD.SystemShortName + ' на ' + NEW.SystemShortName
										ELSE ''
									END
 								ELSE ''
							END	+ CHAR(10)
					FROM 
						dbo.ClientDistrView z
						INNER JOIN dbo.RegProtocol y ON z.HostID = y.RPR_ID_HOST AND z.DISTR = y.RPR_DISTR AND z.COMP = y.RPR_COMP
						OUTER APPLY
							(
								SELECT TOP 1 SystemShortName, NT_SHORT
								FROM
									Reg.RegDistr t
									INNER JOIN Reg.RegHistoryView q WITH(NOEXPAND) ON t.ID = q.ID_DISTR
								WHERE t.ID_HOST = z.HostID AND t.DISTR = z.DISTR AND t.COMP = z.COMP AND dbo.DateOf(q.DATE) < dbo.DateOf(RPR_DATE)
								ORDER BY DATE DESC
							) AS OLD
						OUTER APPLY
							(
								SELECT TOP 1 SystemShortName, NT_SHORT
								FROM
									Reg.RegDistr t
									INNER JOIN Reg.RegHistoryView q WITH(NOEXPAND) ON t.ID = q.ID_DISTR
								WHERE t.ID_HOST = z.HostID AND t.DISTR = z.DISTR AND t.COMP = z.COMP AND dbo.DateOf(q.DATE) >= dbo.DateOf(RPR_DATE)
								ORDER BY DATE
							) AS NEW
					WHERE z.ID_CLIENT = ClientID AND y.RPR_OPER IN ('НОВАЯ', 'Включение', 'Изм. парам.')
						AND RPR_DATE > a.DATE AND RPR_DATE < DATEADD(MONTH, @MON_CNT, a.DATE)
					ORDER BY RPR_DATE, SystemOrder DESC FOR XML PATH('')
				)
		), 1, 1, '')) AS DATA
	FROM
		(
			SELECT ID_CLIENT, MIN(DATE) AS DATE
			FROM dbo.ClientStudy t
			WHERE STATUS = 1
				AND TEACHED = 1
				AND (DATE >= @BEGIN OR @BEGIN IS NULL)
				AND (DATE <= @END OR @END IS NULL)
				AND ID_PLACE IN (1, 2)				
			GROUP BY ID_CLIENT
		) AS a
		INNER JOIN dbo.ClientView WITH(NOEXPAND) ON ID_CLIENT = ClientID	
	WHERE EXISTS
		(
			SELECT *
			FROM 
				dbo.ClientDistrView z
				INNER JOIN dbo.RegProtocol y ON z.HostID = y.RPR_ID_HOST AND z.DISTR = y.RPR_DISTR AND z.COMP = y.RPR_COMP
			WHERE z.ID_CLIENT = ClientID AND y.RPR_OPER IN ('НОВАЯ', 'Включение', 'Изм. парам.') AND RPR_DATE > a.DATE AND RPR_DATE < DATEADD(MONTH, @MON_CNT, a.DATE)
		)
	ORDER BY DATE DESC	
END
