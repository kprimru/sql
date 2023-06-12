USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceTypeTable]
(
        [ServiceTypeID]          Int            Identity(1,1)   NOT NULL,
        [ServiceTypeName]        VarChar(100)                   NOT NULL,
        [ServiceTypeShortName]   VarChar(20)                        NULL,
        [ServiceTypeVisit]       Bit                                NULL,
        [ServiceTypeDefault]     Bit                                NULL,
        [ServiceTypeActive]      Bit                            NOT NULL,
        CONSTRAINT [PK_dbo.ServiceTypeTable] PRIMARY KEY CLUSTERED ([ServiceTypeID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.ServiceTypeTable(ServiceTypeName)] ON [dbo].[ServiceTypeTable] ([ServiceTypeName] ASC);
GO
GRANT SELECT ON [dbo].[ServiceTypeTable] TO claim_view;
GO
