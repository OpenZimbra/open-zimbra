from .pkgspec import PkgSpec
from .specobject import SpecObject
from metux.log import warn

"""Target configuration"""
class TargetSpec(SpecObject):

    """[private]"""
    def __init__(self, name, pool, conf, spec):
        SpecObject.__init__(self, spec)
        self.name = name
        self.pool = pool
        self.conf = conf

    def get_target_name(self):
        return self.name

    def get_pool_name(self):
        if self.pool is None:
            return 'global'
        else:
            return self.pool.name

    def get_aptrepo_path(self):
        if self.pool is None:
            raise Exception("no pool - dont have an aptrepo")
        else:
            return self.pool.get_aptrepo_path()

    """allocate a statfile object for the (per target) package build finish-marker"""
    def get_pkg_build_statfile(self, pkg):
        if isinstance(pkg,PkgSpec):
            pkgname = pkg.name
        else:
            pkgname = pkg

        return self.conf.get_statfile(
            "build."+self.get_pool_name()+"."+self.get_target_name()+"."+pkgname)

    def get_packager(self):
        p = self.get_cf('packager', None)
        if p is None:
            warn("Target %s has no packager specified. Defaulting to apt" % self.name)
            return 'apt'
        return p
