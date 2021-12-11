USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceFlashTable]
(
        [ID_SERVICE]   Int                NOT NULL,
        [ID_FLASH]     VarChar(1023)      NOT NULL,
        [UN_FLASH]     VarChar(50)        NOT NULL,
        [NUM_COUNT]    Int                    NULL,
        [LAST_DATE]    SmallDateTime          NULL,,
        CONSTRAINT [FK_dbo.ServiceFlashTable(ID_SERVICE)_dbo.ServiceTable(ServiceID)] FOREIGN KEY  ([ID_SERVICE]) REFERENCES [dbo].[ServiceTable] ([ServiceID])
);
GO
GRANT DELETE ON [dbo].[ServiceFlashTable] TO public;
GRANT INSERT ON [dbo].[ServiceFlashTable] TO public;
GRANT SELECT ON [dbo].[ServiceFlashTable] TO public;
GRANT UPDATE ON [dbo].[ServiceFlashTable] TO public;
GO
